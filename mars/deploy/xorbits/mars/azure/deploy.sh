#!/bin/bash

function usage() {
  echo "Usage: $0 [OPTIONS]
  OPTIONS:
    -c | --commit VALUE      commit id. Get it from pipeline. (required)
    -h | --host-file VALUE   hosts file path used for pssh. (required)
    -s | --supervisor VALUE  supervisor ip. (required)
    -w | --workers-num VALUE the workers num that you want in mars cluster. (required)
    -l | --local             whether this script runs locally. (default false)"
}

ARGS="$(getopt -a -o c:h:s:w:l \
       --long commit:,host-file:,supervisor:,workers-num:,local,help -- "$@")"

[ $? -ne 0 ] && usage

eval set -- "$ARGS"

# default
run_locally="false"

while true
do
  case $1 in
    -c|--commit)
      commit_id=$2
      shift
      ;;
    -h|--host-file)
      hosts_file_path=$2
      shift
      ;;
    -s|--supervisor)
      supervisor_ip=$2
      shift
      ;;
    -w|--workers-num)
      available_workers_num=$2
      shift
      ;;
    -l|--local)
      run_locally="true"
      ;;
    --help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
shift
done

declare -A build_argument_map
build_argument_map["-c | --commit"]=$commit_id
build_argument_map["-h | --host-file"]=$hosts_file_path
build_argument_map["-s | --supervisor"]=$supervisor_ip
build_argument_map["-w | --workers-num"]=$available_workers_num

function check_arguments() {
  for key in "${!build_argument_map[@]}"; do
    [ ! "${build_argument_map[$key]}" ] && echo "Missing required argument \"$key\" !" && exit 1
  done
}

check_arguments

echo "Arguments:"
echo "commit id: $commit_id"
echo "hosts file path: $hosts_file_path"
echo "supervisor: $supervisor_ip"
echo "workers num: $available_workers_num"
echo "run locally: $run_locally"

if [ "$run_locally" == "true" ] ; then
  set -ex
else
  set -e
fi

function check_prerequisite() {
  if ! command -v "$1"; then
    echo "Need $1."
    exit 1
  fi
}

function check_workers_num() {
  max_worker_num=$(grep -c -v ^$ < "$1")
  if [ "$2" -gt "$max_worker_num" ]; then
    echo "$max_worker_num"
  fi
  if [ "$2" -lt 1 ]; then
      echo 1
  fi
  echo "$2"
}

function check_file_exist() {
  if [ ! -f "$1" ]; then
    echo "$1 does not exit!"
    exit 1
  fi
}

# generate real host file for pssh, according to the config "available_workers_num"
function obtain_real_workers_file() {
  path="$(dirname -- "$1")"
  cat "$1" | sed '/^$/d' | head -n "$2" > "$path"/hosts_"$3".txt
  echo "$path/hosts_$3.txt"
}

function stop_all_docker_containers() {
  # stop all running containers
  if [ "$(sudo docker ps | wc -l)" -gt 1 ]; then
    sudo docker stop "$(sudo docker ps -q)"
  fi
  # rm all the names
  if [ "$(sudo docker ps -a | wc -l)" -gt 1 ]; then
    sudo docker rm "$(sudo docker ps -a | tail -n +2  | awk '{print $NF}' | xargs)"
  fi
}

check_prerequisite pssh
check_prerequisite docker
check_file_exist "$hosts_file_path"
available_workers_num=$(check_workers_num "$hosts_file_path" "$available_workers_num")
hosts_file_path=$(obtain_real_workers_file "$hosts_file_path" "$available_workers_num" "$commit_id")

# stop all the previous docker containers and clean names
stop_all_docker_containers
pssh -h "$hosts_file_path" -i "$(declare -f stop_all_docker_containers); stop_all_docker_containers"

# pull mars image
commit_image="xorbits/mars:"$commit_id
sudo docker pull "$commit_image"
container_name="mars_"$commit_id
sudo docker run --privileged -d --network host --name "$container_name" "$commit_image" tail -f /dev/null

# start supervisor on this machine
sudo docker exec -d "$container_name" mars-supervisor -H "$(hostname -i)" -p 8002 -w 8001

# start worker on other machines
pssh -h "$hosts_file_path" -t 0 -i sudo docker pull "$commit_image"
pssh -h "$hosts_file_path" -i sudo docker run --privileged -d --network host --name "$container_name" "$commit_image" tail -f /dev/null
pssh -h "$hosts_file_path" -i sudo docker exec -d "$container_name" mars-worker -H '$(hostname -i)' -p 8003 -s "$supervisor_ip":8002

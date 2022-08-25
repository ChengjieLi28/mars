#!/bin/bash

if [ $# -lt 4 ]; then
  echo "Usage: $0 commit_id hosts_file_path supervisor_ip available_workers_num run_locally[optional]"
  exit 1
fi

commit_id=$1
hosts_file_path=$2
supervisor_ip=$3
available_workers_num=$4

run_locally="true"
if [ $# -eq 5 ]; then
  run_locally=$5
fi

if "$run_locally" -eq "true" ; then
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
    sudo docker rm "$(sudo docker ps -a | tail -n +2  | awk '{print $NF}')"
  fi
}

check_prerequisite pssh
check_prerequisite docker
check_file_exist "$hosts_file_path"
available_workers_num=$(check_workers_num "$hosts_file_path" "$available_workers_num")
hosts_file_path=$(obtain_real_workers_file "$hosts_file_path" "$available_workers_num" "$commit_id")

# stop all the previous docker containers and clean names
stop_all_docker_containers
pssh -h "$hosts_file_path" "$(declare -f stop_all_docker_containers); stop_all_docker_containers"

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

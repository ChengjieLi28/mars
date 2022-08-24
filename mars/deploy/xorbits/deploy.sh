#!/bin/bash

set -ex

commit_id=$1
hosts_file_path=$2
supervisor_ip=$3
available_workers_num=$4

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

function obtain_real_workers_file() {
  path="$(dirname -- "$1")"
  cat "$1" | sed '/^$/d' | head -n "$2" > "$path"/hosts_"$3".txt
  echo "$path/hosts_$3.txt"
}

function stop_all_docker_containers() {
  if [ "$(sudo docker ps | wc -l)" -gt 1 ]; then
    sudo docker stop "$(sudo docker ps -aq)"
  fi
}

check_prerequisite pssh
check_prerequisite docker
available_workers_num=$(check_workers_num "$hosts_file_path" "$available_workers_num")
hosts_file_path=$(obtain_real_workers_file "$hosts_file_path" "$available_workers_num" "$commit_id")

# stop all the previous docker containers
stop_all_docker_containers
pssh -h "$hosts_file_path" 'if sudo docker stop $(sudo docker ps -aq) ; then echo Stopped; fi'

# pull mars image
commit_image="xorbits/mars:"$commit_id
sudo docker pull "$commit_image"
container_name="mars_"$commit_id
sudo docker run --privileged -d --network host --name "$container_name" "$commit_image" tail -f /dev/null

# start supervisor on this machine
sudo docker exec -d "$container_name" mars-supervisor -H "$(hostname -i)" -p 8002 -w 8001

# start worker on other machines
pssh -h "$hosts_file_path" -t 0 -i sudo docker pull "$commit_image"
# TODO pass MARS_BIND_HOST
pssh -h "$hosts_file_path" -i sudo docker run --privileged -d --network host --name "$container_name" "$commit_image" tail -f /dev/null
pssh -h "$hosts_file_path" -i sudo docker exec -d "$container_name" mars-worker -H '$(hostname -i)' -p 8003 -s "$supervisor_ip":8002

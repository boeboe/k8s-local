#!/usr/bin/env bash
#
# Performance benchmark k8s local bash helper functions
#
ROOT_DIR="$( cd -- "$(dirname "${0}")" >/dev/null 2>&1 ; pwd -P )"
source ${ROOT_DIR}/k8s-local.sh

K8S_VERSION="1.25.9"

echo "Cleaning previous log files" ;
rm -f *.log ;

for k8s_provider in "k3s" "kind" "minikube" ; do
  echo "========== Performance benchmark ${k8s_provider} provider =========="
  if output=$(is_k8s_version_available "${k8s_provider}" "${K8S_VERSION}") ; then
    echo "Kubernetes version '${K8S_VERSION}' for provider ${k8s_provider} found successfully" ;
  else
    echo "Kubernetes version '${K8S_VERSION}' not available for provider ${k8s_provider}, skipping..." ;
    continue ;
  fi

  echo "Starting performance test by spinning up 3 clusters: test1, test2 and test3"
  time (
    start_cluster "${k8s_provider}" "test1" "1.25.9" "test1" "192.168.50.0/24" &> perf-${k8s_provider}-start-test1.log &
    start_cluster "${k8s_provider}" "test2" "1.25.9" "test2" "192.168.51.0/24" &> perf-${k8s_provider}-start-test2.log &
    start_cluster "${k8s_provider}" "test3" "1.25.9" "test3" "192.168.52.0/24" &> perf-${k8s_provider}-start-test3.log &
    wait_cluster_ready "${k8s_provider}" "test1" &> perf-${k8s_provider}-wait-test1.log ;
    wait_cluster_ready "${k8s_provider}" "test2" &> perf-${k8s_provider}-wait-test2.log ;
    wait_cluster_ready "${k8s_provider}" "test3" &> perf-${k8s_provider}-wait-test3.log ;
  )
  echo "Starting clusters: DONE" ; read -p "Press enter to continue" ;

  remove_cluster "${k8s_provider}" "test1" "test1" &> perf-${k8s_provider}-stop-test1.log ;
  remove_cluster "${k8s_provider}" "test2" "test2" &> perf-${k8s_provider}-stop-test2.log ;
  remove_cluster "${k8s_provider}" "test3" "test3" &> perf-${k8s_provider}-stop-test3.log ;
  echo "Removing clusters: DONE" ; read -p "Press enter to continue" ;
done
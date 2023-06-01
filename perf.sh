#!/usr/bin/env bash
#
# Performance benchmark k8s local bash helper functions
#
ROOT_DIR="$( cd -- "$(dirname "${0}")" >/dev/null 2>&1 ; pwd -P )"
source ${ROOT_DIR}/k8s-local.sh

PROVIDER=k3s
# PROVIDER=kind
# PROVIDER=minikube

if ${TEST_K3S} ; then
  echo "========== Performance benchmark ${PROVIDER} provider =========="
  export K8S_LOCAL_PROVIDER=${PROVIDER}
  time (
    start_cluster "test1" "1.25.8" "test1" &
    start_cluster "test2" "1.25.7" "test2" &
    start_cluster "test3" "1.25.6" "test3" &
    wait_cluster_ready "test1";
    wait_cluster_ready "test2";
    wait_cluster_ready "test3";
  )
  echo "Starting clusters: DONE" ; read -p "Press enter to continue" ;

  remove_cluster "test1" "test1";
  remove_cluster "test2" "test2";
  remove_cluster "test3" "test3";
  echo "Removing clusters: DONE" ; read -p "Press enter to continue" ;
fi
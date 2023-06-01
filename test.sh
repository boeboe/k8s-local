#!/usr/bin/env bash
#
# Test k8s local bash helper functions
#
ROOT_DIR="$( cd -- "$(dirname "${0}")" >/dev/null 2>&1 ; pwd -P )"
source ${ROOT_DIR}/k8s-local.sh

# TEST_MINIKUBE=false
# TEST_K3S=false
# TEST_KIND=false
TEST_MINIKUBE=true
TEST_K3S=true
TEST_KIND=true

if ${TEST_MINIKUBE} ; then
  echo "========== Test default provider: minikube =========="
  start_cluster "test1" "1.25.8" "test1";
  start_cluster "test2" "1.25.7" "test2" "192.168.200.0/24";
  start_cluster "test3" "1.25.6" "test3";
  wait_cluster_ready "test1";
  wait_cluster_ready "test2";
  wait_cluster_ready "test3";
  echo "Starting minikube clusters: DONE" ; read -p "Press enter to continue" ;
  remove_cluster "test1" "test1";
  remove_cluster "test2" "test2";
  remove_cluster "test3" "test3";
  echo "Removing minikube clusters: DONE" ; read -p "Press enter to continue" ;
fi

if ${TEST_K3S} ; then
  echo "========== Test k3s provider =========="
  export K8S_LOCAL_PROVIDER=k3s
  start_cluster "test1" "1.25.8" "test1";
  start_cluster "test2" "1.25.7" "test2" "192.168.200.0/24";
  start_cluster "test3" "1.25.6" "test3";
  wait_cluster_ready "test1";
  wait_cluster_ready "test2";
  wait_cluster_ready "test3";
  echo "Starting k3s clusters: DONE" ; read -p "Press enter to continue" ;
  remove_cluster "test1" "test1";
  remove_cluster "test2" "test2";
  remove_cluster "test3" "test3";
  echo "Removing k3s clusters: DONE" ; read -p "Press enter to continue" ;
fi

if ${TEST_KIND} ; then
  echo "========== Test kind provider =========="
  export K8S_LOCAL_PROVIDER=kind
  start_cluster "test1" "1.25.8" "test1";
  start_cluster "test2" "1.25.3" "test2" "192.168.200.0/24";
  start_cluster "test3" "1.25.2" "test3";
  wait_cluster_ready "test1";
  wait_cluster_ready "test2";
  wait_cluster_ready "test3";
  echo "Starting kind clusters: DONE" ; read -p "Press enter to continue" ;
  remove_cluster "test1" "test1";
  remove_cluster "test2" "test2";
  remove_cluster "test3" "test3";
  echo "Removing kind clusters: DONE" ; read -p "Press enter to continue" ;
fi

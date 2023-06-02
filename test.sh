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
  start_cluster "minikube" "test1" "1.25.8" "test1";
  start_cluster "minikube" "test2" "1.25.7" "test2" "192.168.200.0/24";
  start_cluster "minikube" "test3" "1.25.6" "test3";
  wait_cluster_ready "minikube" "test1";
  wait_cluster_ready "minikube" "test2";
  wait_cluster_ready "minikube" "test3";
  echo "Starting minikube clusters: DONE" ; read -p "Press enter to continue" ;
  remove_cluster "minikube" "test1" "test1";
  remove_cluster "minikube" "test2" "test2";
  remove_cluster "minikube" "test3" "test3";
  echo "Removing minikube clusters: DONE" ; read -p "Press enter to continue" ;
fi

if ${TEST_K3S} ; then
  echo "========== Test k3s provider =========="
  start_cluster "k3s" "test1" "1.25.8" "test1";
  start_cluster "k3s" "test2" "1.25.7" "test2" "192.168.200.0/24";
  start_cluster "k3s" "test3" "1.25.6" "test3";
  wait_cluster_ready "k3s" "test1";
  wait_cluster_ready "k3s" "test2";
  wait_cluster_ready "k3s" "test3";
  echo "Starting k3s clusters: DONE" ; read -p "Press enter to continue" ;
  remove_cluster "k3s" "test1" "test1";
  remove_cluster "k3s" "test2" "test2";
  remove_cluster "k3s" "test3" "test3";
  echo "Removing k3s clusters: DONE" ; read -p "Press enter to continue" ;
fi

if ${TEST_KIND} ; then
  echo "========== Test kind provider =========="
  start_cluster "kind" "test1" "1.25.8" "test1";
  start_cluster "kind" "test2" "1.25.3" "test2" "192.168.200.0/24";
  start_cluster "kind" "test3" "1.25.2" "test3";
  wait_cluster_ready "kind" "test1";
  wait_cluster_ready "kind" "test2";
  wait_cluster_ready "kind" "test3";
  echo "Starting kind clusters: DONE" ; read -p "Press enter to continue" ;
  remove_cluster "kind" "test1" "test1";
  remove_cluster "kind" "test2" "test2";
  remove_cluster "kind" "test3" "test3";
  echo "Removing kind clusters: DONE" ; read -p "Press enter to continue" ;
fi

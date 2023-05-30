#!/usr/bin/env bash
#
# Test k8s local bash helper functions
#
ROOT_DIR="$( cd -- "$(dirname "${0}")" >/dev/null 2>&1 ; pwd -P )"
source ${ROOT_DIR}/k8s-local.sh

# K8S_LOCAL_PROVIDER=dummy start_cluster ;

start_cluster ;
K8S_LOCAL_PROVIDER=k3s start_cluster ;
K8S_LOCAL_PROVIDER=kind start_cluster ;
K8S_LOCAL_PROVIDER=minikube start_cluster ;

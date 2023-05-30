#!/usr/bin/env bash
#
# Test k8s local bash helper functions
#
ROOT_DIR="$( cd -- "$(dirname "${0}")" >/dev/null 2>&1 ; pwd -P )"
source ${ROOT_DIR}/k8s-local.sh

# K8S_LOCAL_PROVIDER=dummy start_cluster ;

export K8S_LOCAL_PROVIDER=kind
start_cluster "test" "1.25.8" "test";
# stop_cluster "test";
# start_cluster "testbis" "1.25.9" "testbis";

# sleep 30 ;
# remove_cluster "testbis" "testbis";
# sleep 30 ;
# remove_cluster "test" "test";

# K8S_LOCAL_PROVIDER=k3s start_cluster ;
# K8S_LOCAL_PROVIDER=kind start_cluster ;
# K8S_LOCAL_PROVIDER=minikube start_cluster ;

# Helper functions to start, stop and delete local kubernetes cluster.
# Supported providers include:
#   - k3s from rancher
#   - kind
#   - minikube
#

# Helper function to initialize defaults and do some prerequisite verifications
function precheck {
  K8S_LOCAL_METALLB_STARTIP="${K8S_LOCAL_METALLB_STARTIP:-100}"
  K8S_LOCAL_METALLB_STOPIP="${K8S_LOCAL_METALLB_STOPIP:-199}"
  K8S_LOCAL_PROVIDER="${K8S_LOCAL_PROVIDER:-minikube}"
  K8S_LOCAL_DOCKER_SUBNET_START="${K8S_LOCAL_DOCKER_SUBNET_START:-192.168.49.0/24}"

  # Check if docker is installed
  if ! $(command -v docker &> /dev/null) ; then
    echo "Executable 'docker' could not be found, please install this on your local system first" ;
    exit 1
  fi

  # Check if a valid provider is configured and binary installed if needed
  case ${K8S_LOCAL_PROVIDER} in
    "k3s")
      ;;
    "kind" | "minikube")
      if $(command -v ${K8S_LOCAL_PROVIDER} &> /dev/null) ; then true ; else
        echo "? Executable for provider '${K8S_LOCAL_PROVIDER}' could not be found, please install this on your local system first" ;
        exit 2
      fi
      ;;
    *)
      echo "Unknown K8S_LOCAL_PROVIDER '${K8S_LOCAL_PROVIDER}', quiting..."
      exit 2
      ;;
  esac
}

# Check if a certain subnet is already in use
#   args:
#     (1) network subnet
#   return value:
#     0 : used
#     1 : not used
function is_docker_subnet_used {
  [[ -z "${1}" ]] && echo "Please provide network subnet as 1st argument" && return 2 || subnet="${1}" ;
  docker network ls | tail -n +2 | awk '{ print $2 }' | \
    xargs -I {} -- docker network inspect {} --format '{{ if .IPAM.Config }}{{(index .IPAM.Config 0).Subnet}}{{ end }}' | \
    awk NF | grep ${subnet} &>/dev/null ;
}

# Get a docker subnet that is still free
function get_docker_subnet_free {
  start=$(echo ${K8S_LOCAL_DOCKER_SUBNET_START} |  awk -F '.' '{ print $3;}')
  for i in $(seq ${start} 254) ; do
    check_subnet=$(echo ${K8S_LOCAL_DOCKER_SUBNET_START} |  awk -F '.' "{ print \$1\".\"\$2\".\"${i}\".\"\$4;}")
    if ! $(is_docker_subnet_used "${check_subnet}") ; then
      echo "${check_subnet}" ;
      return
    fi
  done
}

# Get a docker container ip address
#   args:
#     (1) container name
#     (2) network name
function get_docker_container_ip {
  [[ -z "${1}" ]] && echo "Please provide container name as 1st argument" && return || container_name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide network name as 2nd argument" && return || network_name="${2}" ;
  docker container inspect --format "{{(index .NetworkSettings.Networks \"${network_name}\").IPAddress}}" "${container_name}" 
}

# Start a docker network
#   args:
#     (1) network name
#     (2) network subnet
function start_docker_network {
  [[ -z "${1}" ]] && echo "Please provide network name as 1st argument" && return || name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide network subnet as 2nd argument" && return || subnet="${2}" ;
  gateway=$(echo ${subnet} |  awk -F '.' "{ print \$1\".\"\$2\".\"\$3\".\"1;}")
  echo "Starting docker bridge network '${name}' with subnet '${subnet}' and gateway '${gateway}'"
  docker network create \
    --driver="bridge" \
    --opt "com.docker.network.bridge.name=${name}0" \
    --opt "com.docker.network.driver.mtu=1500" \
    --gateway="${gateway}" \
    --subnet="${subnet}" \
    "${name}" ;
  echo "Flushing docker isolation iptable rules"
  sudo iptables -t filter -F DOCKER-ISOLATION-STAGE-2 ;
}

# Remove a docker network
#   args:
#     (1) network name
function remove_docker_network {
  echo "Removing docker bridge network '${1}'"
  docker network rm "${1}"
}

# Start a local k3s cluster
#   args:
#     (1) cluster name
#     (2) k8s version
#     (3) docker network name
#     (4) docker network subnet
function start_k3s_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide k8s version as 2nd argument" && return || k8s_version="${2}" ;
  [[ -z "${3}" ]] && echo "Please provide docker network name as 3rd argument" && return || network_name="${3}" ;
  [[ -z "${4}" ]] && echo "Please provide docker network subnet as 4th argument" && return || network_subnet="${4}" ;

  if $(docker inspect -f '{{.State.Status}}' ${cluster_name} 2>/dev/null | grep "running" &>/dev/null) ; then
    echo "K3s cluster '${cluster_name}' already running"
  elif $(docker inspect -f '{{.State.Status}}' ${cluster_name} 2>/dev/null | grep "exited" &>/dev/null) ; then
    echo "Restarting k3s cluster '${cluster_name}'"
    docker start ${cluster_name} ;
  else
    image="rancher/k3s:v${k8s_version}-k3s1"
    echo "Starting k3s cluster '${cluster_name}':"
    echo "  cluster_name: ${cluster_name}"
    echo "  image: ${image}"
    echo "  k8s_version: ${k8s_version}"
    echo "  network_name: ${network_name}"
    echo "  network_subnet: ${network_subnet}"

    start_docker_network "${network_name}" "${network_subnet}" ;
    docker run \
      --privileged \
      --publish 6443:6443 \
      --name "${cluster_name}" \
      --network ${network_name} \
      ${image} -- \
      server --disable traefik ;

    # docker rename "${cluster_name}-control-plane" "${cluster_name}" ;
    # kubectl config rename-context "kind-${cluster_name}" "${cluster_name}" ;
    kubeapi_address=$(get_docker_container_ip "${cluster_name}" "${network_name}") ;
    echo "kubeapi_address == ${kubeapi_address}"
    # kubectl config set-cluster "kind-${cluster_name}" --server="https://${kubeapi_address}:6443" ;
  fi

  echo "WIP k3s"
}

# Stop a local k3s cluster
#   args:
#     (1) cluster name
function stop_k3s_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  echo "WIP k3s"
}

# Remove a local k3s cluster
#   args:
#     (1) cluster name
function remove_k3s_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  echo "WIP k3s"
}

# Start a local kind cluster
#   args:
#     (1) cluster name
#     (2) k8s version
#     (3) docker network name
#     (4) docker network subnet
function start_kind_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide k8s version as 2nd argument" && return || k8s_version="${2}" ;
  [[ -z "${3}" ]] && echo "Please provide docker network name as 3rd argument" && return || network_name="${3}" ;
  [[ -z "${4}" ]] && echo "Please provide docker network subnet as 4th argument" && return || network_subnet="${4}" ;
  
  if $(docker inspect -f '{{.State.Status}}' ${cluster_name} 2>/dev/null | grep "running" &>/dev/null) ; then
    echo "Kind cluster '${cluster_name}' already running"
  elif $(docker inspect -f '{{.State.Status}}' ${cluster_name} 2>/dev/null | grep "exited" &>/dev/null) ; then
    echo "Restarting kind cluster '${cluster_name}'"
    docker start ${cluster_name} ;
  else
    image="kindest/node:v${k8s_version}"
    echo "Starting kind cluster '${cluster_name}':"
    echo "  cluster_name: ${cluster_name}"
    echo "  image: ${image}"
    echo "  k8s_version: ${k8s_version}"
    echo "  network_name: ${network_name}"
    echo "  network_subnet: ${network_subnet}"

    start_docker_network "${network_name}" "${network_subnet}" ;
    KIND_EXPERIMENTAL_DOCKER_NETWORK=${network_name} kind create cluster --name "${cluster_name}" --image "${image}" ;
    docker rename "${cluster_name}-control-plane" "${cluster_name}" ;
    kubectl config rename-context "kind-${cluster_name}" "${cluster_name}" ;
    kubeapi_address=$(get_docker_container_ip "${cluster_name}" "${network_name}") ;
    kubectl config set-cluster "kind-${cluster_name}" --server="https://${kubeapi_address}:6443" ;
  fi
}

# Stop a local kind cluster
#   args:
#     (1) cluster name
function stop_kind_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  if $(docker inspect -f '{{.State.Status}}' ${cluster_name} | grep "running" &>/dev/null) ; then
    echo "Going to stop kind cluster '${cluster_name}'"
    docker stop ${cluster_name} ;
  fi
}

# Remove a local kind cluster
#   args:
#     (1) cluster name
#     (2) docker network
function remove_kind_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide docker network name as 2nd argument" && return || network_name="${2}" ;
  if $(kind get clusters | grep "${cluster_name}" &>/dev/null) ; then
    echo "Going to remove kind cluster '${cluster_name}'"
    docker rename "${cluster_name}" "${cluster_name}-control-plane" ;
    kubectl config rename-context "${cluster_name}" "kind-${cluster_name}" ;
    kind delete cluster --name "${cluster_name}" ;
    echo "Going to remove docker network '${network_name}'"
    docker network rm ${network_name} ;
  fi
}

# Start a local minikube cluster
#   args:
#     (1) cluster name
#     (2) k8s version
#     (3) docker network name
#     (4) docker network subnet
function start_minikube_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide k8s version as 2nd argument" && return || k8s_version="${2}" ;
  [[ -z "${3}" ]] && echo "Please provide docker network name as 3rd argument" && return || network_name="${3}" ;
  [[ -z "${4}" ]] && echo "Please provide docker network subnet as 4th argument" && return || network_subnet="${4}" ;
  if $(minikube --profile ${cluster_name} status 2>/dev/null | grep "host:" | grep "Running" &>/dev/null) ; then
    echo "Minikube cluster profile '${cluster_name}' already running"
  elif $(minikube --profile ${cluster_name} status 2>/dev/null | grep "host:" | grep "Stopped" &>/dev/null) ; then
    echo "Restarting minikube cluster profile '${cluster_name}'"
    minikube start --driver=docker --profile ${cluster_name} ;
  else
    echo "Starting minikube cluster in minikube profile '${cluster_name}':"
    echo "  cluster_name: ${cluster_name}"
    echo "  k8s_version: ${k8s_version}"
    echo "  network_name: ${network_name}"
    echo "  network_subnet: ${network_subnet}"
    start_docker_network "${network_name}" "${network_subnet}" ;
    minikube start --driver=docker --kubernetes-version=v${k8s_version} --profile=${cluster_name} --network=${network_name} --subnet=${network_subnet} ;
  fi
}

# Stop a local minikube cluster
#   args:
#     (1) cluster name
function stop_minikube_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  if $(minikube --profile ${cluster_name} status 2>/dev/null | grep "host:" | grep "Running" &>/dev/null) ; then
    echo "Going to stop minikube cluster in minikube profile '${cluster_name}'"
    minikube stop --profile ${cluster_name} 2>/dev/null ;
  fi
}

# Remove a local minikube cluster
#   args:
#     (1) cluster name
#     (2) docker network
function remove_minikube_cluster {
  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide docker network name as 2nd argument" && return || network_name="${2}" ;
  if $(minikube profile list --light=true 2>/dev/null | grep ${cluster_name} &>/dev/null) ; then
    echo "Going to remove minikube cluster in minikube profile '${cluster_name}'"
    minikube delete --profile ${cluster_name} 2>/dev/null ;
    echo "Going to remove docker network '${network_name}'"
    docker network rm ${network_name} ;
  fi
}

# Start a local kubernetes cluster
#   args:
#     (1) cluster name
#     (2) k8s version
#     (3) docker network name
#     (4) docker network subnet
function start_cluster {
  precheck ;

  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide k8s version as 2nd argument" && return || k8s_version="${2}" ;
  [[ -z "${3}" ]] && echo "Please provide docker network name as 3rd argument" && return || network_name="${3}" ;
  [[ -z "${4}" ]] && echo "No subnet provided, finding a free one" && network_subnet=$(get_docker_subnet_free) || network_subnet="${4}" ;

  echo "Going to start ${K8S_LOCAL_PROVIDER} based kubernetes cluster '${cluster_name}'"
  case ${K8S_LOCAL_PROVIDER} in
    "k3s")
      start_k3s_cluster "${cluster_name}" "${k8s_version}" "${network_name}" "${network_subnet}" ;
      ;;
    "kind")
      start_kind_cluster "${cluster_name}" "${k8s_version}" "${network_name}" "${network_subnet}" ;
      ;;
    "minikube")
      start_minikube_cluster "${cluster_name}" "${k8s_version}" "${network_name}" "${network_subnet}" ;
      ;;
  esac
}

# Stop a local kubernetes cluster
#   args:
#     (1) cluster name
function stop_cluster {
  precheck ;

  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;

  echo "Going to stop ${K8S_LOCAL_PROVIDER} based kubernetes cluster '${cluster_name}'"
  case ${K8S_LOCAL_PROVIDER} in
    "k3s")
      stop_k3s_cluster "${cluster_name}" ;
      ;;
    "kind")
      stop_kind_cluster "${cluster_name}" ;
      ;;
    "minikube")
      stop_minikube_cluster "${cluster_name}" ;
      ;;
  esac
}

# Remove a local kubernetes cluster
#   args:
#     (1) cluster name
#     (2) docker network
function remove_cluster {
  precheck ;

  [[ -z "${1}" ]] && echo "Please provide cluster name as 1st argument" && return || cluster_name="${1}" ;
  [[ -z "${2}" ]] && echo "Please provide docker network name as 2nd argument" && return || network_name="${2}" ;

  echo "Going to remove ${K8S_LOCAL_PROVIDER} based kubernetes cluster '${cluster_name}'"
  case ${K8S_LOCAL_PROVIDER} in
    "k3s")
      remove_k3s_cluster "${cluster_name}" "${network_name}" ;
      ;;
    "kind")
      remove_kind_cluster "${cluster_name}" "${network_name}" ;
      ;;
    "minikube")
      remove_minikube_cluster "${cluster_name}" "${network_name}" ;
      ;;
  esac
}


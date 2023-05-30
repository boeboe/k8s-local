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
        exit 1
      fi
      ;;
    *)
      echo "Unknown K8S_LOCAL_PROVIDER '${K8S_LOCAL_PROVIDER}', quiting..."
      exit 1
      ;;
  esac
}


# Start a docker network
#   args:
#     (1) network name
#     (2) network subnet
function start_docker_network {
  echo "Starting docker bridge network '${1}' with subnet '${2}'"
  docker network create \
    --driver="bridge" \
    --subnet="${2}"  \
    --opt com.docker.network.bridge.name="${1}0" \
    "${1}"
  echo "Flushing docker isolation iptable rules"
  sudo iptables -t filter -F DOCKER-ISOLATION-STAGE-2
}

# Remove a docker network
#   args:
#     (1) network name
function remove_docker_network {
  echo "Removing docker bridge network '${1}'"
  docker network rm "${1}"
}

# Start a local kubernetes cluster
#   args:
#     (1) cluster name
#     (2) docker network name
#     (3) docker network subnet
#     (4) k8s version
function start_cluster {
  precheck ;

  case ${K8S_LOCAL_PROVIDER} in
    "k3s")
      echo "Going to start k3s based kubernetes cluster"
      start_docker_network "${2}" "${3}"
      ;;
    "kind")
      echo "Going to start kind based kubernetes cluster"
      ;;
    "minikube")
      echo "Going to start minikube based kubernetes cluster"
      ;;
  esac
}

# Stop a local kubernetes cluster
#   args:
#     (1) cluster name
function stop_cluster {
  precheck ;

  case ${K8S_LOCAL_PROVIDER} in
    "k3s")
      echo "Going to stop k3s based kubernetes cluster"
      ;;
    "kind")
      echo "Going to stop kind based kubernetes cluster"
      ;;
    "minikube")
      echo "Going to stop minikube based kubernetes cluster"
      ;;
  esac
}

# Remove a local kubernetes cluster
#   args:
#     (1) cluster name
#     (2) docker network
function remove_cluster {
  precheck ;

  case ${K8S_LOCAL_PROVIDER} in
    "k3s")
      echo "Going to remove k3s based kubernetes cluster"
      ;;
    "kind")
      echo "Going to remove kind based kubernetes cluster"
      ;;
    "minikube")
      echo "Going to remove minikube based kubernetes cluster"
      ;;
  esac
}
# k8s-local

The goal of this bash wrapper functions is to provide a unified interface for local kubernetes multi-cluster
management.

## minikube provider

```console
# kubectl --context test1 get pods -A
NAMESPACE     NAME                            READY   STATUS    RESTARTS       AGE
kube-system   coredns-565d847f94-zw2dm        1/1     Running   0              2m27s
kube-system   etcd-test1                      1/1     Running   0              2m40s
kube-system   kube-apiserver-test1            1/1     Running   0              2m40s
kube-system   kube-controller-manager-test1   1/1     Running   0              2m40s
kube-system   kube-proxy-f785p                1/1     Running   0              2m27s
kube-system   kube-scheduler-test1            1/1     Running   0              2m41s
kube-system   storage-provisioner             1/1     Running   1 (117s ago)   2m40s

# kubectl --context test2 get pods -A
NAMESPACE     NAME                            READY   STATUS    RESTARTS      AGE
kube-system   coredns-565d847f94-8r7lz        1/1     Running   0             98s
kube-system   etcd-test2                      1/1     Running   0             110s
kube-system   kube-apiserver-test2            1/1     Running   0             112s
kube-system   kube-controller-manager-test2   1/1     Running   0             112s
kube-system   kube-proxy-b49tk                1/1     Running   0             99s
kube-system   kube-scheduler-test2            1/1     Running   0             112s
kube-system   storage-provisioner             1/1     Running   1 (67s ago)   110s

# kubectl --context test3 get pods -A
NAMESPACE     NAME                            READY   STATUS    RESTARTS      AGE
kube-system   coredns-565d847f94-mr8x7        1/1     Running   0             64s
kube-system   etcd-test3                      1/1     Running   0             78s
kube-system   kube-apiserver-test3            1/1     Running   0             79s
kube-system   kube-controller-manager-test3   1/1     Running   0             77s
kube-system   kube-proxy-x62g9                1/1     Running   0             64s
kube-system   kube-scheduler-test3            1/1     Running   0             79s
kube-system   storage-provisioner             1/1     Running   1 (34s ago)   76s

# docker ps
CONTAINER ID   IMAGE                                 COMMAND                  CREATED         STATUS         PORTS                                                                                                                                  NAMES
839a1f7a99ad   gcr.io/k8s-minikube/kicbase:v0.0.39   "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes   127.0.0.1:49362->22/tcp, 127.0.0.1:49361->2376/tcp, 127.0.0.1:49360->5000/tcp, 127.0.0.1:49359->6443/tcp, 127.0.0.1:49358->32443/tcp   test1
076c57d63253   gcr.io/k8s-minikube/kicbase:v0.0.39   "/usr/local/bin/entr…"   4 minutes ago   Up 4 minutes   127.0.0.1:49367->22/tcp, 127.0.0.1:49366->2376/tcp, 127.0.0.1:49365->5000/tcp, 127.0.0.1:49364->6443/tcp, 127.0.0.1:49363->32443/tcp   test2
f15329ee5035   gcr.io/k8s-minikube/kicbase:v0.0.39   "/usr/local/bin/entr…"   3 minutes ago   Up 3 minutes   127.0.0.1:49372->22/tcp, 127.0.0.1:49371->2376/tcp, 127.0.0.1:49370->5000/tcp, 127.0.0.1:49369->6443/tcp, 127.0.0.1:49368->32443/tcp   test3

# docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
8608956bdb6b   bridge    bridge    local
2eb5e4626720   host      host      local
bac9c2cd6047   none      null      local
7d3d067cbfaf   test1     bridge    local
ce2f10f0f6ed   test2     bridge    local
ecb9cb661549   test3     bridge    local

# cat ~/.kube/config | grep server -A 1
    server: https://192.168.49.2:6443
  name: test1
--
    server: https://192.168.200.2:6443
  name: test2
--
    server: https://192.168.50.2:6443
  name: test3
```

## k3s provider

```console
# kubectl --context test1 get pods -A
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   local-path-provisioner-79f67d76f8-v6x27   1/1     Running   0          32s
kube-system   coredns-597584b69b-59mzs                  1/1     Running   0          32s
kube-system   metrics-server-5f9f776df5-zzdtp           1/1     Running   0          32s

# kubectl --context test2 get pods -A
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   coredns-597584b69b-sqf5n                  1/1     Running   0          24s
kube-system   local-path-provisioner-79f67d76f8-7x7qg   1/1     Running   0          24s
kube-system   metrics-server-5f9f776df5-rjkcp           1/1     Running   0          24s

# kubectl --context test3 get pods -A
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   coredns-597584b69b-nm7rd                  1/1     Running   0          16s
kube-system   local-path-provisioner-79f67d76f8-9pnjt   1/1     Running   0          16s
kube-system   metrics-server-5f9f776df5-mwdmf           1/1     Running   0          16s

# docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED              STATUS              PORTS                     NAMES
e6eadc96b8e5   rancher/k3s:v1.25.8-k3s1   "/bin/k3d-entrypoint…"   2 minutes ago        Up 2 minutes        0.0.0.0:41351->6443/tcp   test1
29844a759058   rancher/k3s:v1.25.7-k3s1   "/bin/k3d-entrypoint…"   About a minute ago   Up About a minute   0.0.0.0:37701->6443/tcp   test2
361c472cab1a   rancher/k3s:v1.25.6-k3s1   "/bin/k3d-entrypoint…"   About a minute ago   Up About a minute   0.0.0.0:41101->6443/tcp   test3

# docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
8608956bdb6b   bridge    bridge    local
2eb5e4626720   host      host      local
bac9c2cd6047   none      null      local
6c50c0b1229c   test1     bridge    local
750398670f50   test2     bridge    local
122015fe2830   test3     bridge    local

# cat ~/.kube/config | grep server -A 1
    server: https://192.168.49.2:6443
  name: k3d-test1
--
    server: https://192.168.200.2:6443
  name: k3d-test2
--
    server: https://192.168.50.2:6443
  name: k3d-test3
```

## kind provider


```console
# kubectl --context test1 get pods -A
NAMESPACE            NAME                                          READY   STATUS    RESTARTS   AGE
kube-system          coredns-565d847f94-s77pr                      1/1     Running   0          43s
kube-system          coredns-565d847f94-sd7g7                      1/1     Running   0          43s
kube-system          etcd-test1-control-plane                      1/1     Running   0          56s
kube-system          kindnet-fm876                                 1/1     Running   0          43s
kube-system          kube-apiserver-test1-control-plane            1/1     Running   0          58s
kube-system          kube-controller-manager-test1-control-plane   1/1     Running   0          56s
kube-system          kube-proxy-b7k98                              1/1     Running   0          43s
kube-system          kube-scheduler-test1-control-plane            1/1     Running   0          56s
local-path-storage   local-path-provisioner-86666ffff6-x7r87       1/1     Running   0          43s

# kubectl --context test2 get pods -A
NAMESPACE            NAME                                          READY   STATUS    RESTARTS   AGE
kube-system          coredns-565d847f94-69d4t                      1/1     Running   0          29s
kube-system          coredns-565d847f94-scrzz                      1/1     Running   0          29s
kube-system          etcd-test2-control-plane                      1/1     Running   0          43s
kube-system          kindnet-gwxhd                                 1/1     Running   0          30s
kube-system          kube-apiserver-test2-control-plane            1/1     Running   0          45s
kube-system          kube-controller-manager-test2-control-plane   1/1     Running   0          43s
kube-system          kube-proxy-jfn9d                              1/1     Running   0          30s
kube-system          kube-scheduler-test2-control-plane            1/1     Running   0          43s
local-path-storage   local-path-provisioner-684f458cdd-gqs7z       1/1     Running   0          29s

# kubectl --context test3 get pods -A
NAMESPACE            NAME                                          READY   STATUS    RESTARTS   AGE
kube-system          coredns-565d847f94-866sn                      1/1     Running   0          17s
kube-system          coredns-565d847f94-h2l7z                      1/1     Running   0          17s
kube-system          etcd-test3-control-plane                      1/1     Running   0          31s
kube-system          kindnet-jvsrp                                 1/1     Running   0          17s
kube-system          kube-apiserver-test3-control-plane            1/1     Running   0          29s
kube-system          kube-controller-manager-test3-control-plane   1/1     Running   0          29s
kube-system          kube-proxy-f62c6                              1/1     Running   0          17s
kube-system          kube-scheduler-test3-control-plane            1/1     Running   0          29s
local-path-storage   local-path-provisioner-684f458cdd-lf52p       1/1     Running   0          17s

# docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED              STATUS              PORTS                       NAMES
5f83ac69e1f6   kindest/node:v1.25.8   "/usr/local/bin/entr…"   2 minutes ago        Up 2 minutes        127.0.0.1:38333->6443/tcp   test1
645226d82196   kindest/node:v1.25.3   "/usr/local/bin/entr…"   About a minute ago   Up About a minute   127.0.0.1:35377->6443/tcp   test2
ca2edbce5d50   kindest/node:v1.25.2   "/usr/local/bin/entr…"   About a minute ago   Up About a minute   127.0.0.1:35363->6443/tcp   test3

# docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
8608956bdb6b   bridge    bridge    local
2eb5e4626720   host      host      local
bac9c2cd6047   none      null      local
355880fc855a   test1     bridge    local
81ae930b56eb   test2     bridge    local
9f65dcdf14b2   test3     bridge    local

# cat ~/.kube/config | grep server -A 1
    server: https://192.168.49.2:6443
  name: kind-test1
--
    server: https://192.168.200.2:6443
  name: kind-test2
--
    server: https://192.168.50.2:6443
  name: kind-test3
```
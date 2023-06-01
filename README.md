# k8s-local

The goal of this bash wrapper functions is to provide a unified interface for local kubernetes multi-cluster
management.

## k3s provider

```console
# kubectl get pods -A --context test1
NAMESPACE        NAME                                      READY   STATUS    RESTARTS   AGE
kube-system      coredns-597584b69b-t2t5f                  1/1     Running   0          38s
kube-system      local-path-provisioner-79f67d76f8-wdn65   1/1     Running   0          38s
kube-system      metrics-server-5f9f776df5-n6tvd           1/1     Running   0          38s
metallb-system   controller-6658b8446c-jtzdv               1/1     Running   0          38s
metallb-system   speaker-jb5b8                             1/1     Running   0          38s

# kubectl get pods -A --context test2
NAMESPACE        NAME                                      READY   STATUS    RESTARTS   AGE
kube-system      coredns-597584b69b-55dnq                  1/1     Running   0          35s
kube-system      local-path-provisioner-79f67d76f8-zs79f   1/1     Running   0          35s
kube-system      metrics-server-5f9f776df5-x47q4           1/1     Running   0          35s
metallb-system   speaker-qmlkj                             1/1     Running   0          35s
metallb-system   controller-6658b8446c-4hw7v               1/1     Running   0          35s

# kubectl get pods -A --context test3
NAMESPACE        NAME                                      READY   STATUS    RESTARTS   AGE
kube-system      coredns-597584b69b-k2c8c                  1/1     Running   0          30s
kube-system      local-path-provisioner-79f67d76f8-wxtcv   1/1     Running   0          30s
kube-system      metrics-server-5f9f776df5-f5nf2           1/1     Running   0          30s
metallb-system   speaker-9xf65                             1/1     Running   0          30s
metallb-system   controller-6658b8446c-2xcrq               1/1     Running   0          30s

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
# kubectl get pods -A --context test1
NAMESPACE            NAME                                          READY   STATUS    RESTARTS   AGE
kube-system          coredns-565d847f94-46pnq                      1/1     Running   0          75s
kube-system          coredns-565d847f94-vxv82                      1/1     Running   0          75s
kube-system          etcd-test1-control-plane                      1/1     Running   0          90s
kube-system          kindnet-xfjvb                                 1/1     Running   0          76s
kube-system          kube-apiserver-test1-control-plane            1/1     Running   0          90s
kube-system          kube-controller-manager-test1-control-plane   1/1     Running   0          90s
kube-system          kube-proxy-6jl44                              1/1     Running   0          76s
kube-system          kube-scheduler-test1-control-plane            1/1     Running   0          90s
kube-system          metrics-server-cc57dff87-t2n88                1/1     Running   0          75s
local-path-storage   local-path-provisioner-86666ffff6-rzvml       1/1     Running   0          75s
metallb-system       controller-6658b8446c-6tprr                   1/1     Running   0          75s
metallb-system       speaker-844ql                                 1/1     Running   0          70s

# kubectl get pods -A --context test2
NAMESPACE            NAME                                          READY   STATUS    RESTARTS   AGE
kube-system          coredns-565d847f94-p7xmq                      1/1     Running   0          61s
kube-system          coredns-565d847f94-xs5kq                      1/1     Running   0          61s
kube-system          etcd-test2-control-plane                      1/1     Running   0          77s
kube-system          kindnet-q746p                                 1/1     Running   0          62s
kube-system          kube-apiserver-test2-control-plane            1/1     Running   0          76s
kube-system          kube-controller-manager-test2-control-plane   1/1     Running   0          76s
kube-system          kube-proxy-gnpsp                              1/1     Running   0          62s
kube-system          kube-scheduler-test2-control-plane            1/1     Running   0          76s
kube-system          metrics-server-cc57dff87-mj52h                1/1     Running   0          61s
local-path-storage   local-path-provisioner-684f458cdd-8fqjm       1/1     Running   0          61s
metallb-system       controller-6658b8446c-kcpqt                   1/1     Running   0          61s
metallb-system       speaker-qm8d9                                 1/1     Running   0          56s

# kubectl get pods -A --context test3
NAMESPACE            NAME                                          READY   STATUS    RESTARTS   AGE
kube-system          coredns-565d847f94-lrnwm                      1/1     Running   0          48s
kube-system          coredns-565d847f94-wg2t2                      1/1     Running   0          48s
kube-system          etcd-test3-control-plane                      1/1     Running   0          61s
kube-system          kindnet-nklms                                 1/1     Running   0          48s
kube-system          kube-apiserver-test3-control-plane            1/1     Running   0          62s
kube-system          kube-controller-manager-test3-control-plane   1/1     Running   0          61s
kube-system          kube-proxy-24t66                              1/1     Running   0          48s
kube-system          kube-scheduler-test3-control-plane            1/1     Running   0          64s
kube-system          metrics-server-cc57dff87-x8gnn                1/1     Running   0          48s
local-path-storage   local-path-provisioner-684f458cdd-7wn47       1/1     Running   0          48s
metallb-system       controller-6658b8446c-fnrqt                   1/1     Running   0          48s
metallb-system       speaker-vbr24                                 1/1     Running   0          41s

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

## minikube provider

```console
# kubectl get pods -A --context test1
NAMESPACE        NAME                              READY   STATUS    RESTARTS   AGE
kube-system      coredns-565d847f94-qxhnk          1/1     Running   0          6m55s
kube-system      etcd-test1                        1/1     Running   0          7m7s
kube-system      kube-apiserver-test1              1/1     Running   0          7m9s
kube-system      kube-controller-manager-test1     1/1     Running   0          7m8s
kube-system      kube-proxy-p2s2m                  1/1     Running   0          6m55s
kube-system      kube-scheduler-test1              1/1     Running   0          7m8s
kube-system      metrics-server-7bdcf8ff9d-z2cc2   1/1     Running   0          6m55s
kube-system      storage-provisioner               1/1     Running   0          7m7s
metallb-system   controller-6658b8446c-5jrgf       1/1     Running   0          6m55s
metallb-system   speaker-9ltxf                     1/1     Running   0          6m55s

# kubectl get pods -A --context test2
NAMESPACE        NAME                              READY   STATUS    RESTARTS   AGE
kube-system      coredns-565d847f94-lzl44          1/1     Running   0          6m37s
kube-system      etcd-test2                        1/1     Running   0          6m53s
kube-system      kube-apiserver-test2              1/1     Running   0          6m53s
kube-system      kube-controller-manager-test2     1/1     Running   0          6m51s
kube-system      kube-proxy-6n7bz                  1/1     Running   0          6m37s
kube-system      kube-scheduler-test2              1/1     Running   0          6m53s
kube-system      metrics-server-7bdcf8ff9d-84s2g   1/1     Running   0          6m37s
kube-system      storage-provisioner               1/1     Running   0          6m51s
metallb-system   controller-6658b8446c-t5jxg       1/1     Running   0          6m37s
metallb-system   speaker-mqctj                     1/1     Running   0          6m37s

# kubectl get pods -A --context test3
NAMESPACE        NAME                              READY   STATUS    RESTARTS   AGE
kube-system      coredns-565d847f94-btv6s          1/1     Running   0          6m20s
kube-system      etcd-test3                        1/1     Running   0          6m33s
kube-system      kube-apiserver-test3              1/1     Running   0          6m35s
kube-system      kube-controller-manager-test3     1/1     Running   0          6m35s
kube-system      kube-proxy-d5b4g                  1/1     Running   0          6m20s
kube-system      kube-scheduler-test3              1/1     Running   0          6m35s
kube-system      metrics-server-7bdcf8ff9d-t6msd   1/1     Running   0          6m20s
kube-system      storage-provisioner               1/1     Running   0          6m33s
metallb-system   controller-6658b8446c-4qz4p       1/1     Running   0          6m20s
metallb-system   speaker-npf5d                     1/1     Running   0          6m20s

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

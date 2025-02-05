### 卸载 k3s


```shell
# 卸载k3s
/usr/local/bin/k3s-uninstall.sh
# 从agent节点卸载k3s
/usr/local/bin/k3s-agent-uninstall.sh
```

### 安装 k3s

这边安装的是版本是指定版本 `v1.24.9` 

```shell
# 使用命令部署k3s
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.24.9+k3s2 sh -

# 不安装 traefik
# curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.24.9+k3s2 sh -s - --disable traefik

```

**查看所有pod**

```shell
cowain@cowain:~$ sudo kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   local-path-provisioner-687d6d7765-tvpdc   1/1     Running     0          2m37s
kube-system   coredns-7b5bbc6644-p9z6j                  1/1     Running     0          2m37s
kube-system   helm-install-traefik-crd-x9t4p            0/1     Completed   0          2m38s
kube-system   helm-install-traefik-ftd89                0/1     Completed   1          2m38s
kube-system   svclb-traefik-ce8928f1-p8k8w              2/2     Running     0          2m18s
kube-system   metrics-server-667586758d-47hq4           1/1     Running     0          2m37s
kube-system   traefik-64b96ccbcd-m4jv2                  1/1     Running     0          2m18s
```

**保存 kubeconfig**


```shell
cowain@cowain:~/linux-amd64$ sudo mkdir -p /root/.kube
cowain@cowain:~/linux-amd64$ sudo cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
```



### 使用 helm 安装 Rancher 

```shell

## 添加rancher仓库
cowain@cowain:~$ helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

## 创建命名空间
cowain@cowain:~$ sudo kubectl create namespace cattle-system
namespace/cattle-system created

cowain@cowain:~$ sudo kubectl apply -f cert-manager.crds.yaml
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created


## 设置仓库
cowain@cowain:~$ helm repo add jetstack https://charts.jetstack.io
"jetstack" already exists with the same configuration, skipping

## 更新仓库
cowain@cowain:~$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "rancher-latest" chart repository
...Successfully got an update from the "nginx-stable" chart repository


## 安装自签证书
helm install cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --version v1.7.1

## 安装rancher，rancher.copark.com 修改成自己使用的 URL
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.copark.com \
  --set replicas=1 \
  --set bootstrapPassword=admin \
  --dry-run

## 配置本地 host 文件
192.168.70.13 rancher.copark.com
```



### Rancher 添加 k3s 集群

集群管理 - 导入已有集群 - 通用 - 输入集群名称 - 创建

![image-20230216180329547](.\image\image-20230216180329547.png)

不使用证书，添加集群，添加集群之前同样需要添加 host 文件，让加入集群的这台服务器能认识 `rancher.copark.com` 这个URL。

```shell
$ vim /etc/hosts
192.168.70.13 rancher.copark.com
```

执行命令添加进集群

```shell
curl --insecure -sfL https://rancher.copark.com/v3/import/26ckw2h4fscblr2pdkl8vhkg7rhnckn6fh6cm7nrhv2m4kgs6qllbn_c-m-cc4p5q7f.yaml | kubectl apply -f -
```


```shell
kubectl -n cattle-system patch deployments cattle-cluster-agent --patch '{
  "spec": {
      "template": {
          "spec": {
              "hostAliases": [
                  {
                      "hostnames":
                      [
                          "rancher.copark.com"
                      ],
                          "ip": "192.168.70.13"
                  }
              ]
          }
      }
  }
}'

```


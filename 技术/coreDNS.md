> {docsify-updated}

#### **Docker 部署 coreDNS**

```shell
# DNS 服务器
192.168.70.135
```

**新建 coreDNS 配置文件**

```shell
root@cowain-05:~# vim /etc/coredns/corefile

.:53 {
    hosts {
        192.168.70.13     rancher.copark.com
        fallthrough
    }
}
```



```shell
docker run -it -d --name coredns-new --net=host -v /etc/coredns:/etc/coredns/ dalongrong/coredns -conf /etc/coredns/corefile
```



#### **53端口被占用**

```shell
# 查看端口使用情况
root@cowain-05:/etc/coredns# netstat -anp | grep 53
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      584/systemd-resolve
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN      584/systemd-resolve
tcp6       0     80 192.168.70.135:22       172.24.0.201:53214      ESTABLISHED 8823/sshd: root@pts
tcp6       0      0 192.168.70.135:22       172.24.0.201:53215      ESTABLISHED 8825/sshd: root@not
udp        0      0 127.0.0.54:53           0.0.0.0:*                           584/systemd-resolve
udp        0      0 127.0.0.53:53           0.0.0.0:*                           584/systemd-resolve
```

```shell
root@cowain-05:/etc/coredns# systemctl stop systemd-resolved
# 修改配置文件
root@cowain-05:/etc/coredns# vi /etc/systemd/resolved.conf
root@cowain-05:/etc/coredns# ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
```



![image-20230216135258011](.\image\image-20230216135258011.png)



#### 设置 hostfile

```shell
# cat Corefile
.:53 {
    hosts /etc/coredns/hostsfile {
        fallthrough
    }
    forward . 8.8.8.8:53
    log
}

# cat hostsfile
192.168.72.16 example1.org

```



#### 验证域名是否生效

```shell
ping rancher.copark.com
nslookup rancher.copark.com
```

![image-20230217094636840](.\image\image-20230217094636840.png)



#### MySQL 插件

https://coredns.io/explugins/mysql/





#### 参考资料

https://www.cnblogs.com/rongfengliang/p/17065423.html

https://huaweicloud.csdn.net/633112c9d3efff3090b514b0.html




删除`none`的镜像

```shell
docker rmi $(docker images | grep "none" | awk '{print $3}') 
```

删除`tomcat`容器

```shell
docker rm -f $(docker ps | grep tomcat | awk '{print $1}')
```

删除停止的容器

```shell
docker rm `docker ps -a|grep Exited|awk '{print $1}'`
```

设置docker启动就启动容器

```shell
docker container update --restart=always 容器名称
```


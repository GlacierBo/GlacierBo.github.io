创建文件夹

```shell
mkdir my-blog
```

启动容器

```shell
docker run -d -P --name nginx nginx:1.23.0
```

拷贝 nginx 文件

```shell
docker cp nginx:/usr/share/nginx/html my-blog/
docker cp nginx:/etc/nginx/conf.d my-blog/
```

删除容器

```shell
docker stop nginx
docker rm nginx
```



挂载文件，重启容器

```shell
docker run -d -p 80:80 --name nginx \
-v $PWD/my-blog/html:/usr/share/nginx/html \
-v $PWD/my-blog/conf.d:/etc/nginx/conf.d \
nginx:1.23.0
```


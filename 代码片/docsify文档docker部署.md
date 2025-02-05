### docsify文档docker部署

#### Dockerfile

```dockerfile
FROM quintoandar/docsify
ADD . .
```

源码如下：https://www.github.com/quintoandar/docker-docsify

```groovy
FROM node:8.12-alpine
RUN apk add --no-cache tini && npm install -g docsify-cli@latest
WORKDIR /docs
EXPOSE 3000
ENTRYPOINT ["/sbin/tini", "--"]
CMD [ "docsify", "serve", "." ]
```

```shell
$ docker build -t mydocs .
$ docker run -d -v $PWD:/docs:ro -p 4000:4000 --name='docsify' mydocs
$ docker run -d -v $PWD:/docs:ro -p 3000:3000 --name='docsify' quintoandar/docsify
```



```shell

```


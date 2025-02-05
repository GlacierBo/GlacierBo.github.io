### coding 自动化部署项目

以我的博客为例，实现自动化部署



#### 前置条件

coding 账号 https://coding.net/

docsify 生成的文档 https://docsify.js.org/#/

一台装有docker的服务器  https://www.runoob.com/docker/ubuntu-docker-install.html



### 1. docsify 生成文档

https://docsify.js.org/#/quickstart

#### 安装`docsify-cli`

```shell
npm i docsify-cli -g
```

> 或者使用淘宝镜像安装

```shell
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

```shell
cnpm i docsify-cli -g
```



#### 初始化

```shell
docsify init ./doc
```

![image-20230301130820340](.\image\image-20230301130820340.png)



#### 运行

```shell
docsify serve doc
```

![image-20230301131231996](.\image\image-20230301131231996.png)

查看生成的文件，如图有3个

```shell
.nojekyll 这个是构建内容
index.html 这个是首页
REAME.md 这个首页内容
```



![image-20230301130834166](.\image\image-20230301130834166.png)

> 我们甚至可以用 Python 去运行他

在文件夹下使用下面命令

```shell
python -m http.server 3000
```

于是我们创建了一个`bat`脚本

```shell
@echo off

start "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" http://localhost:3000/

python -m http.server 3000
```

填充内容后，启动双击`bat`脚本，在本地查看效果

![image-20230301111639050](.\image\image-20230301111639050.png)

![image-20230301132219045](.\image\image-20230301132219045.png)

### 2. 添加 Dockerfile

```dockerfile
FROM nginx:1.18

EXPOSE 80

COPY . /usr/share/nginx/html/
```

使用`nginx:1.18`作为基础镜像，暴露`80`端口，将文件夹拷贝到`nginx`容器的`html`目录。



### 3. coding.net持续集成 

https://git-scm.com/

https://coding.net/

![image-20230301132931476](.\image\image-20230301132931476.png)

选择`持续集成`开始编写构建计划

![image-20230301133050561](.\image\image-20230301133050561.png)

####  构建的思路

1. 检出代码
2. 打包
3. 构建镜像
4. 推送到制品库
5. 远端服务部署

#### 录入ssh凭证

构建脚本之前，我们先录入ssh凭证，这样`coding`才能操作我们的服务器，跟`jenkins`操作我们服务器一样。

在服务器上生成一个凭据，邮箱随意

```shell
ssh-keygen -m PEM -t rsa -f coding -C "pishi@gmail.com"
```

![image-20230301135137299](.\image\image-20230301135137299.png)

将私钥`coding`录入到ssh私钥中

![image-20230301135325536](.\image\image-20230301135325536.png)

公钥`coding.pub`内容复制，放入被访问服务器`~/.ssh/authorized_keys` 文件中。



#### 构建脚本

选择这个前端模板稍作修改

![image-20230301133652528](.\image\image-20230301133652528.png)

![image-20230301133829014](.\image\image-20230301133829014.png)



因为是静态网页所以不需要安装依赖，也不需要编译打包。

选择制品库的时候没有就去创建一下。

![image-20230301134240346](.\image\image-20230301134240346.png)

录入凭据，保存。

删除“安装依赖”、“漏洞扫描”，映射的端口需要改成 `3000:80`

```shell
docker run -d -p 3000:3000 --name nodejs-express-app ${DOCKER_IMAGE_URL}
```

再添加删除容器、删除镜像的步骤，修改完脚本如下：

```shell
pipeline {
  agent any
  stages {
    stage('检出') {
      steps {
        checkout([$class: 'GitSCM',
        branches: [[name: GIT_BUILD_REF]],
        userRemoteConfigs: [[
          url: GIT_REPO_URL,
          credentialsId: CREDENTIALS_ID
        ]]])
      }
    }

    stage('构建镜像并推送到 CODING Docker 制品库') {
      steps {
        sh "docker build -t ${CODING_DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} -f ${DOCKERFILE_PATH} ${DOCKER_BUILD_CONTEXT}"
        useCustomStepPlugin(key: 'SYSTEM:artifact_docker_push', version: 'latest', params: [image:"${CODING_DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}",repo:"${DOCKER_REPO_NAME}"])
      }
    }

    stage('部署到远端服务') {
      steps {
        script {
          def remoteConfig = [:]
          remoteConfig.name = "my-remote-server"
          remoteConfig.host = "${REMOTE_HOST}"
          remoteConfig.port = "${REMOTE_SSH_PORT}".toInteger()
          remoteConfig.allowAnyHosts = true

          withCredentials([
            sshUserPrivateKey(
              credentialsId: "${REMOTE_CRED}",
              keyFileVariable: "privateKeyFilePath"
            ),
            usernamePassword(
              credentialsId: "${CODING_ARTIFACTS_CREDENTIALS_ID}",
              usernameVariable: 'CODING_DOCKER_REG_USERNAME',
              passwordVariable: 'CODING_DOCKER_REG_PASSWORD'
            )
          ]) {
            // SSH 登录用户名
            remoteConfig.user = "${REMOTE_USER_NAME}"
            // SSH 私钥文件地址
            remoteConfig.identityFile = privateKeyFilePath

            // 请确保远端环境中有 Docker 环境
            sshCommand(
                remote: remoteConfig,
                command: "docker login -u ${CODING_DOCKER_REG_USERNAME} -p ${CODING_DOCKER_REG_PASSWORD} ${CODING_DOCKER_REG_HOST}",
                sudo: true,
              )

                // DOCKER_IMAGE_VERSION 中涉及到 GIT_LOCAL_BRANCH / GIT_TAG / GIT_COMMIT 的环境变量的使用
                // 需要在本地完成拼接后，再传入到远端服务器中使用
                DOCKER_IMAGE_URL = sh(
                  script: "echo ${CODING_DOCKER_REG_HOST}/${CODING_DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}",
                  returnStdout: true
                )

                // 删除容器
                sshCommand(
                  remote: remoteConfig,
                  command: "docker rm -f my-blog | true",
                  sudo: true,
                )
                // 删除镜像
                sshCommand(
                  remote: remoteConfig,
                  command: "docker rmi ${DOCKER_IMAGE_URL}",
                  sudo: true,
                )

                // 拉取镜像
                sshCommand(
                  remote: remoteConfig,
                  command: "docker run -d -p 3000:80 --name my-blog ${DOCKER_IMAGE_URL}",
                  sudo: true,
                )

                echo "部署成功，请到 http://blog.fpdan.cn 预览效果"
              }
            }

          }
        }

      }
      environment {
        CODING_DOCKER_REG_HOST = "${CCI_CURRENT_TEAM}-docker.pkg.${CCI_CURRENT_DOMAIN}"
        CODING_DOCKER_IMAGE_NAME = "${PROJECT_NAME.toLowerCase()}/${DOCKER_REPO_NAME}/${DOCKER_IMAGE_NAME}"
      }
    }
```

#### 测试

将这篇推送到`coding.net`，看到`coding`已经在自动构建了

![image-20230301141017451](.\image\image-20230301141017451.png)

镜像文件打包已经传到我服务器上了

![image-20230301141206814](.\image\image-20230301141206814.png)



访问 `blog.fpdan.cn` 已经看到我的这篇文章了。



### 其他

当然我可以选择用 gitee Page、或者 github.io，更简单方便，所以我为什么要折腾这一下呢。

众所周知我喜欢白嫖。

1.  coding 每个月提供免费的 300min 构建时间，不用白不用

![image-20230301141646623](.\image\image-20230301141646623.png)

2. [【活动】送服务器啦！蓝易云征文大赛](https://fishpi.cn/article/1677580643943)




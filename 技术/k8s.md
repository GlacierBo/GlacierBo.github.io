### 简介

Google 10年容器化基础架构，起源于 borg 的设计思路。

**特点**

1. 轻量级：消耗资源小
2. 开源
3. 弹性伸缩
4. 负载均衡：IPVS

### 知识点

- 介绍说明
  - 前世今生
  - k8s框架
  - k8s关键字含义
- 基础概念
  - 什么是pod
  - 控制器类型
  - k8s网络通讯模式
- k8s
  - 构建k8s集群
- 资源清单
  - 什么事资源
  - 资源清单的语法
  - 编写pod
  - 掌握pod的生命周期
- pod控制器
  - 掌握各种控制器的特点以及使用定义方式
- 服务发现
  - 掌握 svc 原理及其构建方式
- 存储
  - 掌握多重存储类型的特点，并且能在不同环境中选择合适的存储方案（有自己的见解）
- 调度器
  - 掌握调度器原理
  - 能够根据要求把pod定义到想要的节点运行
- 集群安全机制
  - 集群的认证
  - 鉴权
  - 访问控制
  - 原理及其流程
- HELM
  - 掌握HELM原理
  - HELM模板自定义
  - HELM部署常用插件
- 运维
  - 修改Kubeadm达到证书可用期限延长
  - 构建k8s集群高可用



服务分类

有状态服务：DBMS

无状态服务：LVS APACHE



### 组件说明



#### 架构图

borg 架构图

![image-20230210164124970](D:\Desktop\我的\blog\blog\image\image-20230210164124970.png)

k8s 架构图

![image-20230210164321613](D:\Desktop\我的\blog\blog\image\image-20230210164321613.png)



#### etcd

![image-20230210164642858](D:\Desktop\我的\blog\blog\image\image-20230210164642858.png)



#### Master

API server ：集群统一入口，以restful方式，交给etcd存储

scheduler：节点调度，选择node节点应用部署

controller-manager：处理集群中常规后台任务，一个资源对应一个控制器

etcd：存储系统，用于保存集群相关数据

#### node

kubelet：master拍到node节点代表，管理本机容器

kube-proxy：提供网络代理，负载均衡操作



### k8s 核心概念

#### pod

- 最小部署单元
- 一组容器的集合
- 共享网络
- 生命周期是短暂的

#### controller

- 确保预期的pod副本数量
- 有、无状态应用部署
- 确保所有的node运行同一个pod
- 一次性任务和定时任务

#### Service

- 定义一组pod的访问规则


























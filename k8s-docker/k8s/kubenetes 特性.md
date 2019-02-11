**k8s 知识点总结**

[TOC]

# kubenetes 特性

- 足鼎封装、自我修复、水平扩展、服务发现、负载均衡
- 自动发布、回滚
- 秘钥和配置管理

## RESTful

- GET PUT DELETE POST
- kubectl run get edit ...



# Kubenetes资源

## 常用资源对象

- workload: Pod, ReplicaSet, Deployment, StatefulSet, DeamonSet, Job, Cronjob 
- 负载均衡/服务发现：Service, Ingress, ...
- 配置与存储： Volume， CSI
  - cronfigMap，Secret
  - DownwardAPI
- 集群级别资源
  - Namespace， node， role， ClusterRole， RoleBinding ，  ClusterRoleBinding
- 元数据型资源
  - HPA， PodTemplate， LimitRange

##创建资源的方式

apiserver仅接受JSON格式的资源定义；

yaml格式提供配置清单， apiserver可自动将其转为json格式，然后提交

**大部分的资源的配置清单，主要5个一级资源**

- apiVersion

  ```
  kubectl  api-versions 
  ```

- kind： 资源类别

- metadata: 元数据

  - name 

  - namespace
  - labels
  - annotations

  每个资源的引用PATH 路径

  /api/GROUP/VERSION/namespaces/NAMESPACE_NAME/TYPE/NAME

- spec

- status

**使用explain 查看定义**

例如：

```
kubectl explain pods.metadata
kubectl explain pods.spec.containers
```

## Pod 

### pods.spec.containers 必须

```
- name <string>
  image <string>
  imagePullPolicy     <string>  Always, Never, IfNotPresent. 
  * Defaults to Always if :latest tag is specified, or IfNotPresent otherwise. Cannot be updated. (优化点)
 
  ports    <[]Object> 
  * 仅仅是说明性的
  - containerPort <integer> -required-
    hostIP   0.0.0.0
    hostPort  必须与containerPort 相同，大部分不需要定义该项
    name   名称
    protocol 默认TCP
```

- 修改容器的启动命令

```
command      <[]string>
args         <[]string>

- command 会覆盖镜像中的Entrypoint 与 command
- args 会覆盖镜像中的 command
  https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/
```

### nodeSelector <map [string]string>

节点选择器， 限定pod运行在哪些节点上。

使用标签选择器

### nodeName<map [string]string>

直接选择节点

### annotations

注解，仅用于提供”元数据“并不提供 资源兑现选择。没有大小限制。 

### restartPolicy

Always, OnFailure, Never   Default to Always



### pod的生命周期

- 串行执行多个 init_containters（初始化容器），初始化容器执行完成后退出。
- 启动主容器 main containters
  - 启动后可以执行 post start
  - 主进程执行时可以进行健康监测包括：liveness probe 与 readness probe
  - 结束前可以执行 pre stop

**状态**：

- Pending 等待调度，调度未完成

- Running 运行状态

- Failed 失败

- Succeeded

- Unknown

  等等 

**创建Pod：**

apiServer  etcd  scheduler  controller  kubelet 

**容器重启策略**：

restartPolicy



### 健康监测

健康监测主要针对容器，所以在 pod.spec.containers 层级下

**监测类型**

- livenessProbe       存活性探测

- readnessProbe     就绪性监测

  **存活并不一定就绪**

**三种探针类型**

ExecAction、TCPSocketAction、HTTPGetAction

**健康监测主要参数**

- exec  使用命令监测 (重要)

  - command	<[]string>

- httpGet 

- tcpSocket

- initialDelaySeconds (重要) 初始化等待时间

- periodSeconds (重要)  检测间隔时间

- timeoutSeconds <integer> 错误超时时间 默认1秒

- failureThreshold	<integer>  最小失败次数 默认3次

- successThreshold <integer>  最小成功次数 默认1次

  





## 标签labels

labels  与 资源之间是多对多的关系

标签的定义一般从以下几个角度定义

- 版本：alpha beta  canary stable
- 环境：dev pro qa
- 应用名称
- 架构层级
- 分区标签
- 品控标签

标签格式：

```
key=value  
key: 字母 数字 _ .   
value：只能以字母数字开头及结尾
```

通过标签过滤

```
kubectl get pods -l <labels>
```

查看所有标签

```
kubectl get pods --shoe-labels
```

打标签

```
 kubectl label [--overwrite] (-f FILENAME | TYPE NAME) KEY_1=VAL_1 ... KEY_N=VAL_N
[--resource-version=version] [options]
```

**标签选择器**

- 等值关系：=， ==，!=

- 集合关系：

  KEY in (VALUE1,VALUE2, ... )

  KEY not in (VALUE1,VALUE2, ... )

  !KEY  * 不存在键

**许多资源支持内嵌字段**

- matchLabels:     直接给定健值

- matchExpressions: 基于给定的表达式来定义使用标签选择器，{key:"KEY", operator: "OPERATOR", values:[VAL1, VAL2, ...]}

  操作符：In， NotIn, Exists,  NotExists


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

- workload: Pod, ReplicaSet, Deployment, StatefulSet, DaemonSet, Job, Cronjob 
- 负载均衡/服务发现：Service, Ingress, ...
- 配置与存储： Volume， CSI
  - cronfigMap，Secret
  - DownwardAPI
- 集群级别资源
  - Namespace， node， role， ClusterRole， RoleBinding ，  ClusterRoleBinding
- 元数据型资源
  - HPA， PodTemplate， LimitRange



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

k8s管理的最小单位，一个pod中可以有多个contaiers 例如

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        port: 80
      initialDelaySeconds: 2
      periodSeconds: 3
    livenessProbe:
      httpGet:
        port: 80
      initialDelaySeconds: 2
      periodSeconds: 3

  - name: busybox
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    command: ['/bin/sh','-c','ping','www.baidu.com']
  nodeSelector:
    kubernetes.io/hostname: 192.168.0.165
```



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

###  hostNetwork <boolean>

Host networking requested for this pod. Use the host's network namespace.If this option is set, the ports that will be used must be specified. Default to false.

pod直接使用主机的网络名称空间。有用但不常用，默认false。



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

- readinessProbe     就绪性监测

- lifecycle   容器启动后 或者 停止前钩子。

  **存活并不一定就绪**

**三种探针类型**

ExecAction (exec)、TCPSocketAction (tcpSocket)、HTTPGetAction (httpGet)

**健康监测主要参数**

- exec  <Object> 使用命令监测 (重要)

  - command	<[]string>

- httpGet 

- tcpSocket

- initialDelaySeconds (重要) 初始化等待时间

- periodSeconds (重要)  检测间隔时间

- timeoutSeconds <integer> 错误超时时间 默认1秒

- failureThreshold	<integer>  最小失败次数 默认3次

- successThreshold <integer>  最小成功次数 默认1次

  

### lifecycle

容器启动后 或者 停止前钩子。

- postStart
- preStop

**注意：lifecycle的postStart执行在容器command 之后。**

FIELDS:

- exec          <Object>
- httpGet      <Object>   HTTPGet specifies the http request to perform.

### pod 案例

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        port: 80
      initialDelaySeconds: 2
      periodSeconds: 3
    livenessProbe:
      httpGet:
        port: 80
      initialDelaySeconds: 2
      periodSeconds: 3

  - name: busybox
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    command: [ping, www.baidu.com]
  nodeSelector:
    kubernetes.io/hostname: 192.168.0.165
```



## Pod控制器

- ReplicaSet: 控制pod 副本数量，扩缩容机制
- Deployment：ReplicaSet的控制器， 滚动更新、回滚， 声明式定义。无状态服务
- DaemonSet:  确保每个节点执行一个
- Job : 执行一次
- CronJob : 计划任务



- StatefuleSet：有状态的服务
- CDR： Custom Defined Resources
- Operator



1. 用户应该直接操作Deployment。
2. 最好不要将有状态的服务部署在k8s上

### deployment

**更新策略**

**deployment.spec.strategy**

- Recreate
- RollingUpdate
  - maxSurge    Value can be an absolute number (ex: 5) or a percentage of desired  pods (ex: 10%).
  - maxUnavailable  Value can be an absolute number (ex: 5) or a percentage of desired pods (ex:  10%).

**deployment.spec.revisionHistoryLimit**

rc历史保存数量

**案例：**

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    author: huruizhi
    department: opreation
    usage: Java programs k8s template
  labels:
    module_name: pyfinance2v2-register-pro
    env: pro
    kind: deploy
  name: pyfinance2v2-register-pro
  namespace: default
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:    
      maxSurge: 2
      maxUnavailable: 2
  selector:
    matchLabels:
      module_name: pyfinance2v2-register-pro
      env: pro
      kind: pod
  template:
    metadata:
      creationTimestamp: null
      labels:
        module_name: pyfinance2v2-register-pro
        env: pro
        kind: pod
    spec:
      containers:
      - name: pyfinance2v2-register-pro
        image: harbor.pycf.com/pyfinance2v2/register:pro
        imagePullPolicy: Always
        ports:
        - containerPort: 5000 
        command: ['java','-jar','-Xms128m','-Xmx256m','/java8/app.jar','--server.port=5000']
        resources:
          limits:
            memory: 512Mi
          requests:
            memory: 128Mi
        env:
        - name: TZ
          value: Asia/Shanghai
        livenessProbe:
          tcpSocket:
            port: 5000
          initialDelaySeconds: 40
          periodSeconds: 3
        readinessProbe:
          tcpSocket:
            port: 5000
          initialDelaySeconds: 40
          periodSeconds: 3
          
      imagePullSecrets:
      - name: harborkey1
      restartPolicy: Always
```

### DaemSet

在每个节点上部署一个pod

支持滚动更新，支持两种更新模式。可以使用`kubectl explain daemonset.spec.updateStrategy`  查看。

手动更新 `kubectl set image daemonset abc *=nginx:1.9.1`

**案例：**

```
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: filefeat-ds
  namespace: default
  labels:
        app: filebeat
spec:
  selector:
    matchLabels:
      app: filebeat
      release: stable
  template:
    metadata:
      labels:
        app: filebeat
        release: stable
    spec:
      containers:
      - name: filefeat
        image: ikubenetes/filebeat:5.6.5-alpine
        env:
        - name: REDIS_HOST
          value: redis.default.svc.cluster.local
        - name: REDIS_LOG_LEVEL
          value: info
        
```



## Service

Service的名称解析依赖于dns 附件，网络依赖于第三方网络方案。

Service网络是一个虚拟网络，由kube-proxy维护。

工作模式：

- iptables
- ipvs

ipvs没有被激活的情况下自动使用iptables

iptables 查看：

`iptables -L -n  -t nat`

**svc.spec的重要字段**

- ports <[]Object>
  - port
  - nodePort
  - targetPort
- nodepo
- selector
- type ： ExternalName, ClusterIP, NodePort, and LoadBalancer.
- healthCheckNodePort <integer>

**域名后缀**

默认为svc_name.cluster.local.


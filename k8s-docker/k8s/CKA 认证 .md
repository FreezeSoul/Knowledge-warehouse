## CKA 认证

[TOC]

考核日常运维k8s 集群所需的 知识、技能、**熟练度**。

[TOC]



常用 kubectl 命令

Basic Commands（Beginner）:

- create
- expose
- run
- set

Basic Commands（Intermediate）:

-  get
- explain
- edit
- delete

Deploy Command:

- rollout
- rolling-update
- scale
- autoscale

Cluster management Commands：

- certificate
- cluster-info
- top
- cordon
- uncordom
- drain
- taint

Troubleshooting and Debugging Commands：

- describe 
- logs
- attach
- exec
- port-forward
- proxy
- cp

Advanced Commands：

- apply
- patch
- replace
- convert

Setting Commands：

- label
- annotate
- completion    自动补全

Other Commands：

- api-version
- config
- help
- version

## linux 名称空间

[DOCKER基础技术：LINUX NAMESPACE（上）](<https://coolshell.cn/articles/17010.html>)

[DOCKER基础技术：LINUX NAMESPACE（下）](<https://coolshell.cn/articles/17029.html>)

| 分类                   | 作用                                                         |
| ---------------------- | ------------------------------------------------------------ |
| **Mount namespaces**   | 文件系统隔离                                                 |
| **UTS namespaces**     | 主机名和域名的隔离                                           |
| **IPC namespaces**     | IPC全称 Inter-Process Communication，是Unix/Linux下进程间通信的一种方式，IPC有共享内存、信号量、消息队列等方法。 |
| **PID namespaces**     | 隔离进程的ID空间                                             |
| **Network namespaces** | 网络隔离                                                     |
| **User namespaces**    | 用户隔离                                                     |

## Cgroup

[linux  Cgroup介绍](https://www.cnblogs.com/zhengran/p/4436591.html)

##  影响调度的主要属性

node

- **allocatable  可用于调度的资源**
- **capacity  总资源**

pod

- requests
- limits

schedulerName  执行调度的调度器

NodeName

高级调度策略

- nodeSelector
- affinity
- tolerations

### K8S 调度器的资源分配机制

- 基于pod容器request资源 “总和进行” 调度

  - limits 影响pod 运行资源上限， 不影响调度

  - **initContainer** 取最大值 与container 取累加值 最后取大者

    max(max(initContainer.requests),sum(container.requests))

  - 未指定request资源时，按0 进行调度。

-  基于资源声明的调度，而非实际占用

  - 不依赖于监控
  - 调度成功: pod.request < node.allocatable - node.requested

- 资源调度算法

  - GeneralPredicates
  - LesatRequestedPriority
  - BalancedResourceAllocation 平衡 CPU/Mem 消耗的比例

### nodeselector

- 根据 lable 进行节点选择
- 匹配机制 完全匹配

### nodeAffinity

- 引入运算符 In, NotIn, Exists, DoesNotExist. Gt, and Lt
- 支持枚举lable可能的取值
- 支持硬性过滤和软性评分
- 硬性过滤 支持 多条件间的逻辑或
- 软性评分规则 支持 这只条件权重值

### podAffinity/podAntiAffinity

- topologyKey 节点所属的topology范围



### taints

对pod 硬性的排斥

effect类型：

- NoSchedule：仅影响调度过程，对现存的Pod对象不产生影响；
- NoExecute：既影响调度过程，也影响显著的Pod对象；不容忍的Pod对象将被驱逐
- PreferNoSchedule: 表示尽量不调度

TimeAdded： TimeAdded represents the time at which the taint was added. It is only  written for NoExecute taints.

```
kubectl taints
```

### tolerations

pod 的容忍，可以无视排斥

**对于多tains 的 node，pod 必须配置完整的tolerations，与nodeselector 不同**



### 调度失败问题查看

```
错误列表
https://github.com/kubernetes/kubernetes/blob/master/pkg/scheduler/algorithm/predicates/error.go
```



### 多调度器

### 自定义调度器配置

```
kube-scheduler
```



<<<<<<< HEAD
## 网络
=======
## 日志、监控

### 状态

```
kubectl cluster-info
kubectl cluster-info dump
kubectl top node/pod 
```

### k8s组件日志

```
kubectl logs -f {pod name} -c {container name} -n {namespace}
## 进入容器
kubectl exec -it  {pod name} -c {container name} -n {namespace} -- /bin/bash
```

### 日志目录的挂载



## Deployment

### 升级和回滚

```
kubectl set image
kubectl set resource
kubectl edit
kubectl rollout pause
kubectl rollout resume
kubectl rollout status
kubectl rollout history
kubectl rollout undo 

## 伸缩
kubectl scale deploy nginx --replicas=10
kubectl autoscale deployment nginx --min=10 --max=15 --cpu-percent=80
```



### 升级过程定义

```
  strategy:
    type: RollingUpdate
    rollingUpdate: 
      maxSurge: 1
      maxUnavailable: 1
```



### 应用自恢复: restartPolicy + livessnessProbe 

pod. spec.restartPolicy : Always OnFailure

livessnessProbe



### 练习题

1. 通过Deployment 方式，使用redis镜像创建1个pod， 获取启动日志
2. 通过命令行创建1个deployment 副本数为3  镜像为nginx:latest。然后滚动升级搭配nginx:1.9.1

>>>>>>> 846ce4413878ea085026eead2a0e19edc38b9e20

## CKA 认证

考核日常运维k8s 集群所需的 知识、技能、**熟练度**。

- 核心概



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



##  影响调度的主要属性

node

- allocatable  可用于调度的资源
- capacity  总资源

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

  - initContainer 取最大值 与container 取累加值 最后取大者

    max(max(initContainer.requests),sum(container.requests))

  - 未指定request资源时，按0 进行调度。

-  基于资源声明的调度，而非实际占用

  - 不依赖于监控
  - 调度成功: pod.request < node.allocatable - node.requested

- 资源调度算法

  - GeneralPredicates
  - LesatRequestedPriority
  - BalancedResourceAllocation 平衡 CPU/Mem 消耗的比例


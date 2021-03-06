**k8s 知识点总结**

[TOC]

# kubenetes 特性

- 封装、自我修复、水平扩展、服务发现、负载均衡
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
kubectl get pods --show-labels
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



### env环境变量获取

env不仅可以传递key value 的数据，还可以从其他地方传值传递。

**pods.spec.containers.env.valueFrom**

- configMapKeyRef 

  Selects a key of a ConfigMap.

  

- fieldRef     <Object>
  Selects a field of the pod: supports metadata.name, metadata.namespace, metadata.labels, metadata.annotations, spec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP.

  

- resourceFieldRef     <Object>

  Selects a resource of the container: only resources limits and requests  (limits.cpu, limits.memory, limits.ephemeral-storage, requests.cpu, requests.memory and requests.ephemeral-storage) are currently supported.

  

- secretKeyRef <Object>

  Selects a key of a secret in the pod's namespace



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

- ClusterIP 一般不手动指定，可以指定为None 则为无头svc。

  设置成无头svc后 dns中的A记录为pod IP地址，A记录的数量与pod数量相当

  例如使用dig命令查看

  ```
  # dig pyfinance2v2-register-pro.default.svc.cluster.local. @172.20.162.187 
  
  ; <<>> DiG 9.9.4-RedHat-9.9.4-61.el7_5.1 <<>> pyfinance2v2-register-pro.default.svc.cluster.local. @172.20.162.187
  ;; global options: +cmd
  ;; Got answer:
  ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3070
  ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1
  
  ;; OPT PSEUDOSECTION:
  ; EDNS: version: 0, flags:; udp: 4096
  ;; QUESTION SECTION:
  ;pyfinance2v2-register-pro.default.svc.cluster.local. IN        A
  
  ;; ANSWER SECTION:
  pyfinance2v2-register-pro.default.svc.cluster.local. 5 IN A 172.20.197.37
  pyfinance2v2-register-pro.default.svc.cluster.local. 5 IN A 172.20.229.141
  pyfinance2v2-register-pro.default.svc.cluster.local. 5 IN A 172.20.41.13
  
  ;; Query time: 2 msec
  ;; SERVER: 172.20.162.187#53(172.20.162.187)
  ;; WHEN: Wed Feb 13 10:23:49 CST 2019
  ;; MSG SIZE  rcvd: 281
  ```

- ports <[]Object>

  - port
  - nodePort
  - targetPort

- selector

- type ： ExternalName（访问外部服务 例如 GlusterFs）, ClusterIP, NodePort, and LoadBalancer( 外部负载均衡 ).

- healthCheckNodePort <integer>

- sessionAffinity ：ClientIP 和 None  ，负载均衡调度策略。设置为ClientIP 则将同一个ip的连接发送到后端同一个pod上。

**域名后缀**

默认为svc_name.namespace_name.svc.cluster.local.

**案例：**

```
apiVersion: v1
kind: Service
metadata:
  annotations:
    kompose.cmd: kompose convert -f docker-compose-pro.yml
    kompose.version: 1.7.0 (HEAD)
  creationTimestamp: null
  labels:
    io.kompose.service: pyfinance2v2-amc-pro
  name: pyfinance2v2-amc-pro
  namespace: pyfinance2v2-pro
spec:
  type: NodePort
  ports:
  - name: "7562"
    port: 7562
    targetPort: 5000
    nodePort: 7562
  selector:
    io.kompose.service: pyfinance2v2-amc-pro
status:
  loadBalancer: {}
```

## Ingress Controller

外部路由引入，7层负载均衡，可以进行https 卸载。

- HAproxy （不常用）
- Nginx
- Traefik   https://docs.traefik.io/user-guide/kubernetes/
- Envoy

**案例：**

- http ingress:  https://github.com/gjmzj/kubeasz/blob/master/docs/guide/ingress.md

- https ingress:  https://github.com/gjmzj/kubeasz/blob/master/docs/guide/ingress-tls.md

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-nginx-ingress
  namespace: default
spec:
  rules:
  - host: my-nginx.com
    http:
      paths:
      - path: /main
        backend:
          serviceName: my-nginx
          servicePort: 80
      - path: /busybox
        backend:
          serviceName: busybox-demo
          servicePort: 80 
```

**path**: Path is an extended POSIX regex as defined by IEEE Std 1003.1, (i.e this follows the egrep/unix syntax, not the perl syntax) matched against the path of an incoming request. Currently it can contain characters disallowed from the conventional "path" part of a URL as defined by RFC 3986. Paths must begin with a '/'. If unspecified, the path defaults to a catch all  sending traffic to the backend.

例如 path 设置为 /main 则可以访问 /main /main1  等。不能访问 / 、/aaa  等其他路径下资源

## 存储卷管理

- emptyDir 临时存储目录
- hostPath  主机存储
- 网络共享存储： SAN   NAS   分布式存储（glusterfs  rbd cephfs ...）  云存储

### 支持的存储卷类型

```
kubectl explain pod.spec.volumes
kubectl explain persistentVolume.spec
```

定义一个简单的emptyDir, 包涵两个containers。两个容器公用存储卷。

```
apiVersion: v1
kind: Pod
metadata:
  name: busybox-demo
  labels:
    app: busybox
    role: volume_test
spec:
  containers:
  - name: httpd
    image: nginx:latest
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - mountPath: /usr/share/nginx/html/
      name: tmp-volume
  - name: busybox
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    command: ['/bin/sh','-c','while true;do echo $(date) > /data/index.html;sleep 3;done']
    volumeMounts:
    - mountPath: /data/
      name: tmp-volume
  volumes:
  - name: tmp-volume
    emptyDir:
      sizeLimit: 200M
```

### PV 与 PVC 资源

![pv与pvc](./pic/pv_pvc.png)

#### PV对象 及 主要参数

**PV对象不属于名称空间**

**pv.Capacity**

通过capacity给PV设置特定的大小。

**pv.accessModes**

k8s不会真正检查存储的访问模式或根据访问模式做访问限制，只是对真实存储的描述，最终的控制权在真实的存储端。目前支持三种访问模式：

\* ReadWriteOnce – PV以 read-write 挂载到一个节点

\* ReadOnlyMany – PV以read-only方式挂载到多个节点

\* ReadWriteMany – PV以read-write方式挂载到多个节点

**pv.spec.persistentVolumeReclaimPolicy**

当前支持的回收策略:

\* Retain – 允许用户手动回收

\* Recycle – 删除PV上的数据 (“rm -rf /thevolume/*”)

\* Delete – 删除PV



#### PVC对象 与重要参数

**PVC 与PV对象 关联**

**pvc.spec.accessModes**

同 pv对象

**pvc.spec.resources**

- limits
- requests

定义存储大小的需要



**案例  Glusterfs：**

```
apiVersion: v1
kind: Endpoints
metadata:
  name: gfs-endpoint
  labels:
    storage: gfs
subsets:
- addresses:
  - ip: 192.168.0.165
  ports:
  - port: 49158
    protocol: TCP
- addresses:
  - ip: 192.168.0.162
  - ip: 192.168.0.166
  ports:
  - port: 49157
    protocol: TCP
--- 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gfs-pvc
spec:
  accessModes: 
  - ReadWriteMany
  volumeName: gfs-pv
  resources:
    requests:
      storage: 20Gi
---    
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gfs-pv
  labels:
    role: gfs-pv
spec:
  accessModes: 
  - ReadWriteMany
  glusterfs:  
    endpoints: gfs-endpoint
    path: gluster-test
  capacity:
    storage: 20Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gfs-pvc
spec:
  accessModes: 
  - ReadWriteMany
  volumeName: gfs-pv
  resources:
    requests:
      storage: 20Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-demo
  labels:
    app: busybox
    role: volume_test
spec:
  containers:
  - name: httpd
    image: nginx:latest
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - mountPath: /usr/share/nginx/html/busybox
      name: gfs-volume
  - name: busybox
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    command: ['/bin/sh','-c','while true;do echo $(date) >> /data/index.html;sleep 3;done']
    volumeMounts:
    - mountPath: /data/
      name: gfs-volume
  volumes:
  - name: gfs-volume
    persistentVolumeClaim:
      claimName: gfs-pvc
```



### StorageClass 动态生成pv

### 容器配置管理 secret 与 configmap

可以使用环境变量以及 挂载的方式配置到pod当中。

**注意：环境变量的方式只能在容器启动的时候注入，更新configmap 不会更新容器中环境变量的值。使用挂载的方式可以实时更新。**

创建configMap 有多种方式

- 使用kubectl create命令行方式

```
  # Create a new configmap named my-config based on folder bar
  kubectl create configmap my-config --from-file=path/to/bar
  
  # Create a new configmap named my-config with specified keys instead of file basenames on disk
  kubectl create configmap my-config --from-file=key1=/path/to/bar/file1.txt --from-file=key2=/path/to/bar/file2.txt
  
  # Create a new configmap named my-config with key1=config1 and key2=config2
  kubectl create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2
  
  # Create a new configmap named my-config from the key=value pairs in the file
  kubectl create configmap my-config --from-file=path/to/bar
  
  # Create a new configmap named my-config from an env file
  kubectl create configmap my-config --from-env-file=path/to/bar.env
```

- 使用yaml文件

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-cfg
  namespace: default
data:
  cache_host: memcached-gcxt
  cache_port: "11211"
  cache_prefix: gcxt
  my.cnf: |
    [mysqld]
    log-bin = mysql-bin
  app.properties: |
    property.1 = value-1
    property.2 = value-2
    property.3 = value-3
```

使用命令行创建更灵活。

**可以使用inotify监控配置文件实现重载**

例如:

```
#!/bin/sh
oldcksum=`cksum /etc/nginx/conf.d/default.conf`

inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M' --format '%T' \
/etc/nginx/conf.d/ | while read date time; do

    newcksum=`cksum /etc/nginx/conf.d/default.conf`
    if [ "$newcksum" != "$oldcksum" ]; then
        echo "At ${time} on ${date}, config file update detected."
        oldcksum=$newcksum
        nginx -s reload
    fi

done
```

关于configmap的详细总结： https://www.cnblogs.com/breezey/p/6582082.html



## StatefuleSet

**特点：**

1. 稳定且唯一的网络标识符；
2. 稳定且持久的存储；
3. 有序、平滑的部署和扩展；
4. 有序、平滑的删除和终止；
5. 有序的滚动更新；

**三个主要组件：**headless service 、 StatefulSet、 volumeClaimTemplate

名称解析：

pod_name,service_name.ns_name.svc.cluster.local



**更新策略**

sts.spec.updateStrategy.rollingUpdate

- partition  定义更新的边界，例如 定义为3 则编号 >=3的 pod会更新，模拟金丝雀发布

**PV定义**

```
apiVersion: v1
kind: Endpoints
metadata:
  name: gfs-endpoint
  labels:
    storage: gfs
subsets:
- addresses:
  - ip: 192.168.0.165
  ports:
  - port: 49158
    protocol: TCP
- addresses:
  - ip: 192.168.0.162
  - ip: 192.168.0.166
  ports:
  - port: 49157
    protocol: TCP

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: gfs-pv-01
  labels:
    role: gfs-pv-01
spec:
  accessModes: 
  - ReadWriteMany
  - ReadWriteOnce
  glusterfs:  
    endpoints: gfs-endpoint
    path: pv-01
  capacity:
    storage: 5Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gfs-pv-02
  labels:
    role: gfs-pv-02
spec:
  accessModes:
  - ReadWriteMany
  - ReadWriteOnce
  glusterfs:
    endpoints: gfs-endpoint
    path: pv-02
  capacity:
    storage: 5Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gfs-pv-03
  labels:
    role: gfs-pv-03
spec:
  accessModes:
  - ReadWriteMany
  - ReadWriteOnce
  glusterfs:
    endpoints: gfs-endpoint
    path: pv-03
  capacity:
    storage: 5Gi
--- 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gfs-pv-04
  labels:
    role: gfs-pv-04
spec:
  accessModes:
  - ReadWriteMany
  - ReadWriteOnce
  glusterfs:
    endpoints: gfs-endpoint
    path: pv-04
  capacity:
    storage: 5Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gfs-pv-05
  labels:
    role: gfs-pv-05
spec:
  accessModes:
  - ReadWriteMany
  - ReadWriteOnce
  glusterfs:
    endpoints: gfs-endpoint
    path: pv-05
  capacity:
    storage: 5Gi
```

**StatefulSet定义**

```
apiVersion: v1
kind: Service
metadata:
  name: myapp-svc
  labels:
    roles: myapp-svc-test
spec:
  clusterIP: None
  ports:
  - targetPort: 80
    port: 80
  selector:
    roles: myapp-pod
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: myapp-sts
  labels:
    roles: myapp-sts-test
spec:
  replicas: 3
  serviceName: myapp-svc
  selector: 
    matchLabels:
      roles: myapp-pod
  template:
    metadata:
      labels:
        roles: myapp-pod
    spec:
      containers:
       - name: httpd
         image: nginx:latest
         imagePullPolicy: IfNotPresent
         volumeMounts:
         - mountPath: /usr/share/nginx/html/busybox
           name: gfs-volume
  volumeClaimTemplates:
  - metadata:
      name: gfs-volume
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 5Gi
  updateStrategy:
    rollingUpdate: 
      partition: 2
```

 

# k8s认证

**主要使用 RBAC授权检查机制**
**认证：**  token  ssl(双向认证\加密会话) 
**授权检查**
**准入控制**

## 客户端 --->  API Server
API Server 对用户权限的判断需要以下：
user： username uid
group：
extra：

- 开启api代理
```
kubectl proxy
```
HTTP request verb
  get  post  put delte
API request verb
  get list create update  path watch(- w) proxy redirect deletecollection
Resource:
Subresource
namespace
Api group

## RBCA

### k8s 用户类型

-  user  
- group 
- serviceaccount

**serviceaccount 创建**

```
kubectl create serviceaccount default-ns-admin -n default
kubectl create rolebinding default-ns-admin --clusterrole=admin --serviceaccount=default:default-ns-admin  

## 获取serviceaccount的 token 需要用base64解密
kubectl get secrets default-ns-admin-token-2tm4n -o jsonpath={.data.token}|base64 -d
```

**用户ssl 认证相关**

```
https://github.com/huruizhi/Knowledge-warehouse/blob/master/linux总结/CA证书与https讲解.md
https://github.com/gjmzj/kubeasz/blob/master/docs/setup/01-CA_and_prerequisite.md
```

kubeconfig 配置kubectl 连入apiServer的配置

```
# kubectl config view 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: REDACTED
    server: https://192.168.0.200:8443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: admin
  name: kubernetes
current-context: kubernetes
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
```

一个客户端可以配置连接多个集群

context用于定义账号与集群的关系，current-context定义当前访问的集群。

**RBAC（Role-Based Access Control）**

基于角色的访问控制

![RBAC](./pic/RBAC.png)

- role/clusterrole:
  - operations
  - objects
- rolebinding/clusterrolebinding
  - user or service account
  - role

**role 与 rolebinding在名称空间内定义及在当前名称空间内生效。**

**clusterrole 与clusterrolebinding 在集群中定义且在 整个集群内生效**

**注意：也可以建立clusterrole 使用 rolebing 进行绑定。**

clusterrole 与clusterrolebinding 

- subject 类型：

 user  group  serviceaccount

role clusterrole:

- object:
  - resource group
  - resource
  - nonResourceURLs
- action： get, list, watch, patch,  delete, deletecollection

### dashboard 的认证登录

- 认证账号类型必须是ServiceAccount 类型，使用rolebinding或者clusterrolebing 进行权限的赋予
- 使用`kubectl get secrets default-ns-admin-token-2tm4n -o jsonpath={.data.token}|base64 -d`获取token
- kubconfig 方式 是token 的封装

使用 kubeconfig 生成 kubeconfig 文件 使用参数 --kubeconfig 指定文件

# kubernetes网络通信

需要解决的问题：

- 同一个pod内部的不同容器间通信, lo
- Pod间的通信
- pod与Service的通信: PodIP<--->ClusterIP
- Service 与集群外部通信

CNI：

- flannel
- calico
- canel
- kube-router

解决方案：

- 虚拟网桥
- 多路复用：MacVLAN
- 硬件交换：SR-IOV

## flannel

**查看集群的flannel 配置文件**

`cat /etc/cni/net.d/10-flannel.conflist `

**不支持网络策略**  不同namespace 的pod 可以相互通信

支持的后端

- Vxlan 
  - vxlan
  - Directrouting
- host-gw： Host Gateway
- UDP： 效率很低

**flannel 的配置参数：**

- network  

  使用CIRD格式的网络地址：

  10.244.0.0/16 ->

   	master: 10.244.0.0/24

  ​	node1:  10.244.1.0/24

  ​	...

   	node255:  10.244.255.0/24

- SubnetLen 

  在node上使用多长的掩码 默认 24位

- SubnetMin 与SubnetMax  

  网段中最小的子网网段与最大的子网网段。

- Backend： 选择flannel的类型



**修改flannel 类型**

修改配置文件  kube-flannel.yaml

```
  net-conf.json: |
    {
      "Network": "172.20.0.0/16",
      "Backend": {
        "Type": "vxlan"
        "Direcrouting": true
      }
    }
```





## Calico/Cannel

可以提供网络策略

https://docs.projectcalico.org/v3.5/getting-started/kubernetes/installation/other

**networkpolicy.spec**

```
   egress	<[]Object>
     List of egress rules to be applied to the selected pods. Outgoing traffic
     is allowed if there are no NetworkPolicies selecting the pod (and cluster
     policy otherwise allows the traffic), OR if the traffic matches at least
     one egress rule across all of the NetworkPolicy objects whose podSelector
     matches the pod. If this field is empty then this NetworkPolicy limits all
     outgoing traffic (and serves solely to ensure that the pods it selects are
     isolated by default). This field is beta-level in 1.8

   ingress	<[]Object>
     List of ingress rules to be applied to the selected pods. Traffic is
     allowed to a pod if there are no NetworkPolicies selecting the pod OR if
     the traffic source is the pod's local node, OR if the traffic matches at
     least one ingress rule across all of the NetworkPolicy objects whose
     podSelector matches the pod. If this field is empty then this NetworkPolicy
     does not allow any traffic (and serves solely to ensure that the pods it
     selects are isolated by default).

   podSelector	<Object> -required-
     Selects the pods to which this NetworkPolicy object applies. The array of
     ingress rules is applied to any pods selected by this field. Multiple
     network policies can select the same set of pods. In this case, the ingress
     rules for each are combined additively. This field is NOT optional and
     follows standard label selector semantics. An empty podSelector matches all
     pods in this namespace.

   policyTypes	<[]string>
     List of rule types that the NetworkPolicy relates to. Valid options are
     Ingress, Egress, or Ingress,Egress. If this field is not specified, it will
     default based on the existence of Ingress or Egress rules; policies that
     contain an Egress section are assumed to affect Egress, and all policies
     (whether or not they contain an Ingress section) are assumed to affect
     Ingress. If you want to write an egress-only policy, you must explicitly
     specify policyTypes [ "Egress" ]. Likewise, if you want to write a policy
     that specifies that no egress is allowed, you must specify a policyTypes
     value that include "Egress" (since such a policy would not include an
     Egress section and would otherwise default to just [ "Ingress" ]). This
     field is beta-level in 1.8
```

**注意：如果是定义egress-only 策略，则需要显式的声明Egress。如果需要一个拒绝所有出流量的策略，需要在value中包含Egress，因为如果不包含egress，默认只包含ingress。**

**阻止所有ingress, 允许所有Egress**

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

**允许所有ingress，允许所有Egress**

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
```

**阻止所有Egress**

```**
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

**案例：**

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
```

**总结**

1. NetworkPolicy 针对 namespace 中的 pod 生效。
2. 默认ingress 禁止， egreess 放行。要默认禁止 egress 需要在 policyTypes 的 value 中加入 egress。
3. NetworkPolicy 在定义流量匹配上与防火墙类似。
4. 一般来说对于 提供服务的pod 应该按一下规则定义
   - 默认关闭所有出入栈
   - 放行本namespace 中的所有
   - 定义外部流量

# k8s调度器、预选策略、优选函数

**节点选择过程：**

- 节点预选过程（predicate）
- 优选过程（priority）
- 选定节点（select）

## 调度器

### 预选策略

- CheckNodeCondition：检查节点是否正常
- GeneralPredicates：
  - Hostname：检查pod对象是否定义了pod.spec.host 
  - PodFitsHostPorts：检查pod对象的 pod.spec.containers.ports.hostport
  - MatchNodeSelector：检查pod.spec.nodeSelector
  - PodFitsResources：检查pod对资源的需求能否被资源满足
- （默认不启用）NoDiskConflict：检查pod依赖的存储卷 是否能满足需求
- PodToleratesNodeTains： 检查污点与容忍。pod.spec.tolerations
- （默认不启用）PodToleratesNodenoExcuteTains：驱离污点
- （默认不启用）checkNodeLabelPresence：检查标签的存在性
- （默认不启用）checkServiceAffinity：将 同一个service 下的pod 尽可能放在一个Node下

- MaxEBSVolumeCount
- MaxGCEPDVolumeCount
- MaxAzureDiskVolumeCount

- CheckVolumeBinding：
- NoVolumeZoneConflict：

- CheckNodeMemoryPressure： 检查内存压力
- CheckNodePIDPressure：检查进程压力
- CheckNodeDiskPressure

- MatchInterPodAffitnity： pod间的亲和性

### 优选函数

https://github.com/kubernetes/kubernetes/tree/master/pkg/scheduler/algorithm/priorities

- LeastRequested：按照资源使用量得分
- BalancedResourceAllocation ： CPU和内存资源占用率相近的胜出。平衡资源使用情况
- NodePreferAvoidPods：根据节点的注解信息 "scheduler.aplpha.kubernetes.io/preferAvoidPods" Node 倾向于不
- TainToleration：将pod对象的spec.tolerations 与node的Tain进行匹配度检查，匹配的条目越多，得分越低。
- SelectorSpreading：尽可能的将相同标签选择器的pod 分散在不同的node上。
- InterPodAffinity：亲和性匹配项
- nodeAffinity：节点亲和性
- （默认不启用）MostRequested：服务器空闲度越低，越优先
- （默认不启用）NodeLabel：根据node标签评分
- （默认不启用）imageLocality：节点上是否有需求的镜像，根据镜像的体积大小之和计算



**根据预选与优选 影响pod  的节点选择，主要可以通过污点、pod亲和性、node亲和性。**

## 高级调度设置机制

- 节点选择器/节点亲和调度：nodeSelector,  nodeName, nodeAffinity

  

### node选择器/node亲和调度

- nod.spec.nodeName : 根据node 名称选择
- nod.spec.nodeSelector：根据node 的标签进行选择

**强约束，条件不满足则pedding**

- pod.spec.affinity.nodeAffinity
  - preferredDuringSchedulingIgnoredDuringExecution  非强制性 ，多条件权重
  - requiredDuringSchedulingIgnoredDuringExecution   强制性

### pod亲和性

- pod.spec.affinity.podAffinity
  - preferredDuringSchedulingIgnoredDuringExecution  非强制性
  - requiredDuringSchedulingIgnoredDuringExecution  强制性
    - labelSelector
    - namespace
    - topologykey  必须的  affinity、anti-affinity



### 污点调度 Taints 与 Tolerations

**Taints 给予node定义，那些pod可以执行**

**pod 使用 Tolerations指定容忍的污点 **

**node.spec.taints**

```
FIELDS:
   effect	<string> -required-
     Required. The effect of the taint on pods that do not tolerate the taint.
     Valid effects are NoSchedule, PreferNoSchedule and NoExecute.

   key	<string> -required-
     Required. The taint key to be applied to a node.

   timeAdded	<string>
     TimeAdded represents the time at which the taint was added. It is only
     written for NoExecute taints.

   value	<string>
     Required. The taint value corresponding to the taint key.
```

**effect: 用于定义排斥的行为：**

- NoSchedule ：仅仅影响调度过程，对已经存在的pod不产生影响。
-  PreferNoSchedule：最好不调度，但是可容忍。
- NoExecute：既影响调度过程，也影响存在的pod对象。驱逐。

**管理节点污点**

```
 kubectl taint NODE NAME KEY_1=VAL_1:TAINT_EFFECT_1 ... KEY_N=VAL_N:TAINT_EFFECT_N [options]
```



**pod.spec.tolerations**

可以让pod 容忍 node 上的污点。

```
FIELDS:
   effect	<string>
     Effect indicates the taint effect to match. Empty means match all taint
     effects. When specified, allowed values are NoSchedule, PreferNoSchedule
     and NoExecute.

   key	<string>
     Key is the taint key that the toleration applies to. Empty means match all
     taint keys. If the key is empty, operator must be Exists; this combination
     means to match all values and all keys.

   operator	<string>
     Operator represents a key's relationship to the value. Valid operators are
     Exists and Equal. Defaults to Equal. Exists is equivalent to wildcard for
     value, so that a pod can tolerate all taints of a particular category.

   tolerationSeconds	<integer>
     TolerationSeconds represents the period of time the toleration (which must
     be of effect NoExecute, otherwise this field is ignored) tolerates the
     taint. By default, it is not set, which means tolerate the taint forever
     (do not evict). Zero and negative values will be treated as 0 (evict
     immediately) by the system.

   value	<string>
     Value is the taint value the toleration matches to. If the operator is
     Exists, the value should be empty, otherwise just a regular string.
```



# 容器的资源限制

requests（ 资源需求，最低保障 ）：

limits（ 资源限制，硬限制 ）：

**CPU：** 指CPU线程，一个线程 1000m

**内存**

**QoS Class：自动生成** 

- Guranteed（优先级高）

  同时设置CPU与内存的request和limits

  ​	CPU.limits=CPU.request

   	memory.limits=CPU.request

- Burstable（优先级中）

  至少一个容器设置了CPU或memory的request

- BestEffort（优先级低）

  没有任何一个容器被设置了request和limits

**当服务器的资源不够用的时候**

- 会优先杀掉 **优先级低** 的容器。
- 按照需求量，占用 **比率高** 的被杀掉。



## HeapSter+InfluxDB+Grafana（1.10之前的版本 已经不建议使用）

资源使用量数据采集工具

- cAdvisor：集成与kunelet，收集node上 pod级别的用量
- HeapSter： 收集汇总数据
- InfluxDB：持久化数据
- Grafana：展示数据

https://github.com/huruizhi/kubeasz/blob/master/docs/guide/heapster.md





## 资源指标API 与 自定义指标API

- 资源指标
- 自定义指标



**新一代架构**

- 核心指标流水线：kubelet   metric-server  与  API Server 提供的api；监控CPU累计使用率，内存实时使用率，Pod的资源占用与node的磁盘占用率。

- 监控流水线：从系统手机各种指标数据提供给终端用户、存储系统与HPA，非核心指标不能被k8s所解析。



## metric-server

资源指标

**kube-aggregator** 作为代理将核心指标的访问指向apiserver，将用户自定义的指标指向metric-server



![](./pic/k8s-aggregator.png)



## prometheus + k8s-prometheus-adapter

自定义指标

https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/prometheus

![prometheus架构图](./pic/promethues-architecture.png)

**注意：推荐使用helm安装部署prometues**

## HPA 应用自动伸缩

  kubectl autoscale (-f FILENAME | TYPE NAME | TYPE/NAME) [--min=MINPODS] --max=MAXPODS
[--cpu-percent=CPU] [options]

`kubectl explain hpa.spec.scaleTargetRef`



# Helm

Chart仓库 

helm 架构 https://helm.sh/docs/architecture/

**主要概念**

- chart 创建Kubernetes应用程序实例所必需的一组信息
- config 包含可以合并到打包chart中 以创建r elease 对象的配置信息。
- release chart 的运行实例，具有特定的config

**组件**

Helm有两个主要组成部分：

**Helm Client** 是最终用户的命令行客户端。客户负责以下功能：

- 本地chart开发
- 管理 仓库
- 与Tiller服务器交互
  - 发送要安装的chart
  - 查询有关release的信息
  - 请求升级或卸载现有的 releases

**Tiller Server** 是一个集群内服务器，与Helm客户端交互，并与Kubernetes API服务器连接。服务器负责以下事项：

- 侦听来自Helm client 的传入请求
- 结合chart和config来构建版本
- 将Chart安装到Kubernetes中，然后跟踪 release
- 通过与Kubernetes交互来升级和卸载Charts

简而言之，客户端负责管理图表，服务器负责管理版本。

## helm 命令

```
helm search
helm repo update
helm list

release 管理
helm inspect  # 查看chart信息
helm install  
helm delete
helm upgrade
helm rolleback

char 操作
helm create
helm fetch
helm inpect  查看chart的详细信息
helm package 打包chart文件
```



## 使用阿里云的helm仓库

```
helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.5.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```

## [自定义charts](https://helm.sh/docs/developing_charts/)

```
wordpress/
  Chart.yaml          # A YAML file containing information about the chart
  LICENSE             # OPTIONAL: A plain text file containing the license for the chart
  README.md           # OPTIONAL: A human-readable README file
  requirements.yaml   # OPTIONAL: A YAML file listing dependencies for the chart
  values.yaml         # The default configuration values for this chart
  charts/             # A directory containing any charts upon which this chart depends.
  templates/          # A directory of templates that, when combined with values,
                      # will generate valid Kubernetes manifest files.
  templates/NOTES.txt # OPTIONAL: A plain text file containing short usage notes
```

**THE CHART.YAML FILE**

The `Chart.yaml` file is required for a chart. It contains the following fields:

```yaml
apiVersion: The chart API version, always "v1" (required)
name: The name of the chart (required)
version: A SemVer 2 version (required)
kubeVersion: A SemVer range of compatible Kubernetes versions (optional)
description: A single-sentence description of this project (optional)
keywords:
  - A list of keywords about this project (optional)
home: The URL of this project's home page (optional)
sources:
  - A list of URLs to source code for this project (optional)
maintainers: # (optional)
  - name: The maintainer's name (required for each maintainer)
    email: The maintainer's email (optional for each maintainer)
    url: A URL for the maintainer (optional for each maintainer)
engine: gotpl # The name of the template engine (optional, defaults to gotpl)
icon: A URL to an SVG or PNG image to be used as an icon (optional).
appVersion: The version of the app that this contains (optional). This needn't be SemVer.
deprecated: Whether this chart is deprecated (optional, boolean)
tillerVersion: The version of Tiller that this chart requires. This should be expressed as a SemVer range: ">2.0.0" (optional)
```



**requirements.yaml**

A `requirements.yaml` file is a simple file for listing your dependencies.

```yaml
dependencies:
  - name: apache
    version: 1.2.3
    repository: http://example.com/charts
  - name: mysql
    version: 3.2.1
    repository: http://another.example.com/charts
```

使用`helm dep`下载依赖

```console
$ helm dep up foochart
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "local" chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "example" chart repository
...Successfully got an update from the "another" chart repository
Update Complete. Happy Helming!
Saving 2 charts
Downloading apache from repo http://example.com/charts
Downloading mysql from repo http://another.example.com/charts
```



**自动生成目录结构**

**go 模板语法**



**helm 自定义仓库主要命令**

```
# 创建helm仓库
helm create

# helm 检测语法
helm lint

# helm 打包
helm package

# 启动本地helm 端口8879
helm serve

helm delete --purge

```





# Istio

- 连接( Connect )
- 安全( Secure )
- 控制( Control )
- 观察( Observe )

**功能**

- 流量管理
  - 负载均衡
  - 动态路由
  - 灰度发布
  - 故障注入
- 可观察性
  - 调用链
  - 访问日志
  - 监控
- 策略执行
  - 限制流量
  - ACL
- 服务身份和安全
  - 认证
  - 鉴权

**扩展能力**

- 平台支持
  - k8s
  - Cloudfoundry
  - Eureka
  - consul
- 集成和定制
  - ACL
  - 日志
  - 配额

## 架构

[](./pic/istioarch.svg)





```
sudo cp -n /lib/systemd/system/docker.service /etc/systemd/system/docker.service
sudo sed -i "s|ExecStart=/usr/bin/docker daemon|ExecStart=/usr/bin/docker daemon --registry-mirror=https://rflxlgcf.mirror.aliyuncs.com|g" /etc/systemd/system/docker.service
sudo sed -i "s|ExecStart=/usr/bin/dockerd|ExecStart=/usr/bin/dockerd --registry-mirror=https://rflxlgcf.mirror.aliyuncs.com|g" /etc/systemd/system/docker.service
sudo systemctl daemon-reload
sudo service docker restart
```




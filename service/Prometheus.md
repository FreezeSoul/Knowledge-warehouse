- # Prometheus 介绍

  ## 实验介绍

  ### 实验内容

  [Prometheus](https://prometheus.io/)（简称 Prom） 是新一代的监控系统，配置简单却灵活，对容器、微服务等支持良好。本次实验我们先来了解一下 Prometheus 的基础概念。

  ### 实验知识点

  - Prometheus 总览
  - Prometheus 跟其它监控系统对比
  - Prometheus 核心概念

  ## 介绍

  ## Prometheus 总览

  Prometheus 是一个开源监控系统，它前身是 [SoundCloud](http://soundcloud.com/) 的告警工具包。从 2012 年开始，许多公司和组织开始使用 Prometheus。该项目的开发人员和用户社区非常活跃，越来越多的开发人员和用户参与到该项目中。目前它是一个独立的开源项目，且不依赖于任何公司。为了强调这点和明确该项目治理结构，Prometheus 在 2016 年继[Kurberntes](http://kubernetes.io/) 之后，加入了 [Cloud Native Computing Foundation](https://cncf.io/)。

  ### 主要特性

  - 多维度数据模型
  - 灵活的查询语言
  - 不依赖任何分布式存储
  - 常见方式是通过拉取方式采集数据
  - 也可通过中间网关支持推送方式采集数据
  - 通过服务发现或者静态配置来发现监控目标
  - 支持多种图形界面展示方式

  ### 架构

  下面这张图描述了 Prometheus 的整体架构，以及其生态中的一些常用组件。

  ![此处输入图片的描述](https://doc.shiyanlou.com/document-uid606277labid6277timestamp1525146475288.png/wm)

  Prometheus Server 采用拉取方式从监控目标直接拉取数据，或者通过中间网关间接地拉取监控目标推送给网关的数据。它在本地存储抓取的数据，通过一定规则进行清理和整理数据，然后把得到的结果存储起来。各种 Web UI 使用 PromQL 查询语言来从 Server 里获取数据。当 Server 监测到有异常时会推送告警给 Alertmanager，Alertmanager 负责去通知相关人。

  ## Prometheus 跟其它监控系统对比

  ### Prometheus vs. Zabbix

  - [Zabbix](https://www.zabbix.com/) 使用的是 C 和 PHP, Prometheus 使用 Golang, 整体而言 Prometheus 运行速度更快一点。
  - Zabbix 属于传统主机监控，主要用于物理主机、交换机、网络等监控，Prometheus 不仅适用主机监控，还适用于 Cloud、SaaS、Openstack、Container 监控。
  - Zabbix 在传统主机监控方面，有更丰富的插件。
  - Zabbix 可以在 WebGui 中配置很多事情，Prometheus 需要手动修改文件配置。

  ### Prometheus vs. Nagios

  - [Nagios](https://www.nagios.org/) 数据不支持自定义 Labels, 不支持查询，告警也不支持去噪、分组, 没有数据存储，如果想查询历史状态，需要安装插件。
  - Nagios 是上世纪 90 年代的监控系统，比较适合小集群或静态系统的监控Nagios 太古老，很多特性都没有，Prometheus 要优秀很多。

  ### Prometheus vs Sensu

  - [Sensu](https://sensuapp.org/) 广义上讲是 Nagios 的升级版本，它解决了很多 Nagios 的问题，如果你对 Nagios 很熟悉，使用 Sensu 是个不错的选择。
  - Sensu 依赖 RabbitMQ 和 Redis，数据存储上扩展性更好。

  ### Prometheus vs InfluxDB

  - [InfluxDB](https://www.influxdata.com/) 是一个开源的时序数据库，主要用于存储数据，如果想搭建监控告警系统，需要依赖其他系统。
  - InfluxDB 在存储水平扩展以及高可用方面做的更好, 毕竟核心是数据库。

  ## Prometheus 核心概念

  ### 数据模型

  Prometheus 从根本上存储的所有数据都是时间序列数据（Time Serie Data，简称时序数据）。时序数据是具有时间戳的数据流，该数据流属于某个度量指标（Metric）和该度量指标下的多个标签（Label）。除了提供存储功能，Prometheus 还可以利用查询表达式来执行非常灵活和复杂的查询。

  #### 度量指标和标签

  每个时间序列（Time Serie，简称时序）由度量指标和一组标签键值对唯一确定。

  度量指标名称描述了被监控系统的某个测量特征（比如 http_requests_total 表示 http 请求总数）。度量指标名称由 ASCII 字母、数字、下划线和冒号组成，须匹配正则表达式 `[a-zA-Z_:][a-zA-Z0-9_:]*`。

  标签开启了 Prometheus 的多维数据模型。对于同一个度量指标，不同标签值组合会形成特定维度的时序。Prometheus 的查询语言可以通过度量指标和标签对时序数据进行过滤和聚合。改变任何度量指标上的任何标签值，都会形成新的时序。标签名称可以包含 ASCII 字母、数字和下划线，须匹配正则表达式 `[a-zA-Z_][a-zA-Z0-9_]*`，带有 _ 下划线的标签名称保留为内部使用。标签值可以包含任意 Unicode 字符，包括中文。

  #### 采样值（Sample）

  时序数据其实就是一系列采样值。每个采样值包括：

  - 一个 64 位的浮点数值
  - 一个精确到毫秒的时间戳

  #### 注解（Notation）

  一个注解由一个度量指标和一组标签键值对构成。形式如下：

  ```
  [metric name]{[label name]=[label value], ...}
  ```

  例如，度量指标为 api_http_requests_total，标签为 method="POST"、handler="/messages" 的注解表示如下：

  ```
  api_http_requests_total{method="POST", handler="/messages"}
  ```

  ### 度量指标类型

  Prometheus 里的度量指标有以下几种类型。

  #### 计数器（Counter）

  计数器是一种累计型的度量指标，它是一个只能递增的数值。计数器主要用于统计类似于服务请求数、任务完成数和错误出现次数这样的数据。

  #### 计量器（Gauge）

  计量器表示一个既可以增加, 又可以减少的度量指标值。计量器主要用于测量类似于温度、内存使用量这样的瞬时数据。

  #### 直方图（Histogram）

  直方图对观察结果（通常是请求持续时间或者响应大小这样的数据）进行采样，并在可配置的桶中对其进行统计。有以下几种方式来产生直方图（假设度量指标为 <basename>）：

  - 按桶计数，相当于 `<basename>_bucket{le="<upper inclusive bound>"}`
  - 采样值总和，相当于 `<basename>_sum`
  - 采样值总数，相当于 `<basename>_count` ，也等同于把所有采样值放到一个桶里来计数 `<basename>_bucket{le="+Inf"}`

  #### 汇总（Summary）

  类似于直方图，汇总也对观察结果进行采样。除了可以统计采样值总和和总数，它还能够按分位数统计。有以下几种方式来产生汇总（假设度量指标为 <basename>）：

  - 按分位数，也就是采样值小于该分位数的个数占总数的比例小于 φ，相当于 `<basename>{quantile="<φ>"}`
  - 采样值总和，相当于 `<basename>_sum`
  - 采样值总数，相当于 `<basename>_count`

  ### 任务（Job）和实例（Instance）

  在 Prometheus 里，可以从中抓取采样值的端点称为实例，为了性能扩展而复制出来的多个这样的实例形成了一个任务。

  例如下面的 api-server 任务有四个相同的实例：

  ```
  job: api-server
  instance 1: 1.2.3.4:5670
  instance 2: 1.2.3.4:5671
  instance 3: 5.6.7.8:5670
  instance 4: 5.6.7.8:5671
  ```

  Prometheus 抓取完采样值后，会自动给采样值添加下面的标签和值：

  - job: 抓取所属任务。
  - instance: 抓取来源实例

  另外每次抓取时，Prometheus 还会自动在以下时序里插入采样值：

  - `up{job="[job-name]", instance="instance-id"}`：采样值为 1 表示实例健康，否则为不健康
  - `scrape_duration_seconds{job="[job-name]", instance="[instance-id]"}`：采样值为本次抓取消耗时间
  - `scrape_samples_post_metric_relabeling{job="<job-name>", instance="<instance-id>"}`：采样值为重新打标签后的采样值个数
  - `scrape_samples_scraped{job="<job-name>", instance="<instance-id>"}`：采样值为本次抓取到的采样值个数

# Prometheus 安装配置和使用

## 实验介绍

### 实验内容

本次实验我们将先安装 Prometheus，然后学习 Prometheus 的常用配置，最后学习 Prometheus 的基本用法。

### 实验知识点

- 安装
- 配置
- 使用

## 安装

### 二进制安装包方式

二进制安装包方式非常简单，实验环境里推荐使用这种方式。首先下载安装包 [prometheus-2.2.1.linux-amd64.tar.gz](http://labfile.oss.aliyuncs.com/courses/1102/prometheus-2.2.1.linux-amd64.tar.gz)（实验楼提供的是 64 位 Linux 平台的安装包，其它平台可从 [官网](https://prometheus.io/download/) 下载），然后解压即可。

```
$ wget http://labfile.oss.aliyuncs.com/courses/1102/prometheus-2.2.1.linux-amd64.tar.gz
$ tar xvfz prometheus-2.2.1.linux-amd64.tar.gz
$ cd prometheus-2.2.1.linux-amd64
$ ./prometheus
```

上面的命令会在默认的 9090 端口启动 Prometheus 服务，打开地址 [http://localhost:9090/](http://localhost:9090/) 即可看到其 Web 界面。

### 源码方式

Prometheus 是开源的，因此可以下载源码到本地来编译安装。这种方式比较麻烦，适合想学习源码或做二次开发的人。感兴趣的同学可以自行研究，这里就不做讲解了。

### Docker 方式

如果当前部署环境支持 Docker，那么可以采取 Docker 方式来运行 Prometheus 服务。使用下面的命令来启动一个 Prometheus 容器：

```
$ docker run -p 9090:9090 prom/prometheus
```

上面把容器内的 9090 端口映射到了宿主机的 9090 端口，因此可以在宿主机上通过 [http://localhost:9090/](http://localhost:9090/) 来访问容器内的 Prometheus 服务。

> Docker 的使用后面会有一系列专门的实验来讲解，不熟悉的同学可以先跳过。

## 配置

### 概述

执行 `prometheus` 命令的时候可以通过参数 `--config.file` 来指定配置文件路径，默认会使用同目录下的 `prometheus.yml` 文件。Prometheus 服务运行过程中如果配置文件有改动，可以给服务进程发送 `SIGHUP` 信号来通知服务进程重新从磁盘加载配置。这样无需重启，可以避免中断服务。

下面会逐一讲解 Prometheus 的核心配置，示例中用到的各种占位符包括：

- <boolean>: 布尔值，true 或 false
- <duration>: 持续时间，格式符合正则表达式 [0-9]+(ms|[smhdwy])
- <labelname>: 标签名，格式符合正则表达式 [a-zA-Z_][a-zA-Z0-9_]*
- <labelvalue>: 标签值，可以包含任意 unicode 字符
- <filename>: 文件名，任意有效的文件路径
- <host>: 主机，可以是主机名或 IP，后面可跟端口号
- <path>: URL 路径
- <scheme>: 协议，http 或 https
- <string>: 字符串
- <secret>: 密钥，比如密码
- <tmpl_string>: 模板字符串，里面包含需要展开的变量

配置文件格式为 YAML，下面是一个配置文件示例：

```
global:
  # 抓取间隔，默认为 1m
  [ scrape_interval: <duration> | default = 1m ]

  # 抓取超时时间，默认为 10s
  [ scrape_timeout: <duration> | default = 10s ]

  # 规则评估间隔，默认为 1m
  [ evaluation_interval: <duration> | default = 1m ]

# 抓取配置
scrape_configs:
  [ - <scrape_config> ... ]

# 规则配置
rule_files:
  [ - <filepath_glob> ... ]

# 告警配置
alerting:
  alert_relabel_configs:
    [ - <relabel_config> ... ]
  alertmanagers:
    [ - <alertmanager_config> ... ]
```

- `global` 全局配置节点下的配置对所有其它节点都有效，同时也是其它节点的默认值。
- `rule_files` 规则配置包含记录规则配置和告警规则配置，节点下只是列出文件，具体配置在各个文件中。记录规则配置接下来会讲，告警规则配置在后面的告警实验中会讲解。
- `alerting` 告警配置用于 Alertmanager，在告警实验中会讲解。

### 抓取配置

抓取配置可以有多个，一般来说每个任务（Job）对应一个配置。单个抓取配置的格式如下：

```
# 任务名
job_name: <job_name>

# 抓取间隔，默认为对应全局配置
[ scrape_interval: <duration> | default = <global_config.scrape_interval> ]

# 抓取超时时间，默认为对应全局配置
[ scrape_timeout: <duration> | default = <global_config.scrape_timeout> ]

# 协议，默认为 http，可选 https
[ scheme: <scheme> | default = http ]

# 抓取地址的路径，默认为 /metrics
[ metrics_path: <path> | default = /metrics ]

# 抓取地址的参数
params:
  [ <string>: [<string>, ...] ]

# 是否尊重抓取回来的标签，默认为 false
[ honor_labels: <boolean> | default = false ]

# 静态目标配置
static_configs:
  [ - <static_config> ... ]

# 单次抓取的采样值个数限制，默认为 0，表示没有限制
[ sample_limit: <int> | default = 0 ]
```

`honor_labels` 表示是否尊重抓取回来的标签。当抓取回来的采样值的标签值跟服务端配置的不一致时，如果该配置为 true，则以抓取回来的为准。否则以服务端的为准，抓取回来的值会保存到一个新标签下，该新标签名在原来的前面加上了“exported_”，比如 exported_job。

`static_configs` 下配置了该任务要抓取的所有实例，按组配置，包含相同标签的实例可以分为一组，以简化配置。单个组的配置格式如下：

```
# 目标地址列表，地址由主机+端口组成
targets:
  [ - '<host>' ]

# 标签列表
labels:
  [ <labelname>: <labelvalue> ... ]
```

抓取目标除了采用静态配置方式，还可以动态发现。动态发现依赖于一个服务发现服务（比如 Consul，可以从这个服务里查询到目前系统里的服务列表），适合监控目标非常多并且经常变化的场景。因为使用场景比较少，在以后需要的时候大家可以去进一步研究。

### 记录规则配置

记录规则允许我们把一些经常需要使用并且查询时计算量很大的查询表达式，预先计算并保存到一个新的时序。查询这个新的时序比从原始一个或多个时序实时计算快得多，并且还能够避免不必要的计算。在一些特殊场景下这甚至是必须的，比如仪表盘里展示的各类定时刷新的数据，数据种类多且需要计算非常快。

记录规则配置文件的格式如下：

```
groups:
  [ - <rule_group> ]
```

记录规则配置按组来组织，一个组下的所有规则按顺序定时执行。单个组的格式如下：

```
# 组名，在文件内唯一
name: <string>

# 规则评估间隔，默认为对应的全局配置
[ interval: <duration> | default = global.evaluation_interval ]

rules:
  [ - <rule> ... ]
```

每个组下包含多条规则，格式如下：

```
# 规则名称，也就是该规则产生的时序数据的度量指标名
record: <string>

# PromQL 查询表达式，表示如何得到采样值
expr: <string>

# 关联标签
labels:
  [ <labelname>: <labelvalue> ]
```

## 使用

学会安装和配置之后，接下来我们通过使用 Prometheus 监控其自身来学习 它的基本用法。

### 配置 Prometheus 监控其自身

Prometheus 服务本身也通过路径 /metrics 暴露了其内部的各项度量指标，我么只需要把它加入到监控目标里就可以。

```
global:
  # 全局默认抓取间隔
  scrape_interval: 15s

scrape_configs:
  # 任务名
  - job_name: 'prometheus'

    # 本任务的抓取间隔，覆盖全局配置
    scrape_interval: 5s

    static_configs:
      # 抓取地址同 Prometheus 服务地址，路径为默认的 /metrics
      - targets: ['localhost:9090']
```

配置完成后启动服务：

```
$ ./prometheus
```

![此处输入图片的描述](https://doc.shiyanlou.com/document-uid606277labid6278timestamp1525146751794.png/wm)

可打开地址 `http://localhost:9090/metrics` 来确认是否有抓取到数据。

### 使用表达式浏览器来查询数据

在本地打开页面 `http://localhost:9090/`，会自动跳转到 Graph 页。在这个页面里可以执行表达式来查询数据，数据展示方式支持 Console 文本方式和 Graph 图形方式。可从 `Execute`后面的下拉列表里选择某个度量指标，或者手动输入任意合法的 PromQL 表达式。

比如选择或输入 `prometheus_target_interval_length_seconds` 会查询到该度量指标相关的所有时序，这里共有四个。

![此处输入图片的描述](https://doc.shiyanlou.com/document-uid606277labid6278timestamp1525146784394.png/wm)

Console 方式列出匹配的所有时序，以及每个时序的最新采样值。

![此处输入图片的描述](https://doc.shiyanlou.com/document-uid606277labid6278timestamp1525146804708.png/wm)

Graph 方式以图形式展示匹配的所有时序最近一段时间内的采样值，默认为最近一小时。

`prometheus_target_interval_length_seconds` 这个度量指标的含义是实际抓取目标时的间隔秒数。可以使用表达式 `prometheus_target_interval_length_seconds{quantile="0.99"}` 来查询 0.99 分位线的采样值，也就是小于这个采样值的数量低于总数的 99%。使用表达式 `count(prometheus_target_interval_length_seconds)` 可以查询到该度量指标包含的时序个数。关于查询表达式的更多语法后续实验会讲到。



# Prometheus 查询语言

## 实验介绍

### 实验内容

PromQL（Prometheus Query Language）是 Prometheus 自己开发的表达式语言，语言表现力很丰富，内置函数也很多。使用它可以对时序数据进行筛选和聚合。本次实验我们将来学习它。

### 实验知识点

- PromQL 语法
- PromQL 操作符
- PromQL 函数

## PromQL 语法

### 数据类型

PromQL 表达式计算出来的值有以下几种类型：

- 瞬时向量 (Instant vector): 一组时序，每个时序只有一个采样值
- 区间向量 (Range vector): 一组时序，每个时序包含一段时间内的多个采样值
- 标量数据 (Scalar): 一个浮点数
- 字符串 (String): 一个字符串，暂时未用

### 时序选择器

#### 瞬时向量选择器

瞬时向量选择器用来选择一组时序在某个采样点的采样值。

最简单的情况就是指定一个度量指标，选择出所有属于该度量指标的时序的当前采样值。比如下面的表达式：

```
http_requests_total
```

可以通过在后面添加用大括号包围起来的一组标签键值对来对时序进行过滤。比如下面的表达式筛选出了 job 为 prometheus，并且 group 为 canary 的时序：

```
http_requests_total{job="prometheus", group="canary"}
```

匹配标签值时可以是等于，也可以使用正则表达式。总共有下面几种匹配操作符：

- =：完全相等
- !=: 不相等
- =~: 正则表达式匹配
- !~: 正则表达式不匹配

下面的表达式筛选出了 environment 为 staging 或 testing 或 development，并且 method 不是 GET 的时序：

```
http_requests_total{environment=~"staging|testing|development",method!="GET"}
```

度量指标名可以使用内部标签 `__name__` 来匹配，表达式 `http_requests_total` 也可以写成 `{__name__="http_requests_total"}`。表达式 `{__name__=~"job:.*"}` 匹配所有度量指标名称以 `job:` 打头的时序。

#### 区间向量选择器

区间向量选择器类似于瞬时向量选择器，不同的是它选择的是过去一段时间的采样值。可以通过在瞬时向量选择器后面添加包含在 `[]` 里的时长来得到区间向量选择器。比如下面的表达式选出了所有度量指标为 http_requests_total 且 job 为 prometheus 的时序在过去 5 分钟的采样值。

```
http_requests_total{job="prometheus"}[5m]
```

时长的单位可以是下面几种之一：

- s：seconds
- m：minutes
- h：hours
- d：days
- w：weeks
- y：years

#### 偏移修饰器

前面介绍的选择器默认都是以当前时间为基准时间，偏移修饰器用来调整基准时间，使其往前偏移一段时间。偏移修饰器紧跟在选择器后面，使用 `offset` 来指定要偏移的量。比如下面的表达式选择度量名称为 http_requests_total 的所有时序在 5 分钟前的采样值。

```
http_requests_total offset 5m
```

下面的表达式选择 http_requests_total 度量指标在 1 周前的这个时间点过去 5 分钟的采样值。

```
http_requests_total[5m] offset 1w
```

## PromQL 操作符

### 二元操作符

PromQL 的二元操作符支持基本的逻辑和算术运算，包含算术类、比较类和逻辑类三大类。

#### 算术类二元操作符

算术类二元操作符有以下几种：

- +：加
- -：减
- *：乘
- /：除
- %：求余
- ^：乘方

算术类二元操作符可以使用在标量与标量、向量与标量，以及向量与向量之间。

> 二元操作符上下文里的向量特指瞬时向量，不包括区间向量。

- 标量与标量之间，结果很明显，跟通常的算术运算一致。
- 向量与标量之间，相当于把标量跟向量里的每一个标量进行运算，这些计算结果组成了一个新的向量。
- 向量与向量之间，会稍微麻烦一些。运算的时候首先会为左边向量里的每一个元素在右边向量里去寻找一个匹配元素（匹配规则后面会讲），然后对这两个匹配元素执行计算，这样每对匹配元素的计算结果组成了一个新的向量。如果没有找到匹配元素，则该元素丢弃。

#### 比较类二元操作符

比较类二元操作符有以下几种：

- == (equal)
- != (not-equal)
- \> (greater-than)
- < (less-than)
- \>= (greater-or-equal)
- <= (less-or-equal)

比较类二元操作符同样可以使用在标量与标量、向量与标量，以及向量与向量之间。默认执行的是过滤，也就是保留值。可以通过在运算符后面跟 `bool` 修饰符来使得返回值 0 和 1，而不是过滤。

- 标量与标量之间，必须跟 bool 修饰符，因此结果只可能是 0（false） 或 1（true）。
- 向量与标量之间，相当于把向量里的每一个标量跟标量进行比较，结果为真则保留，否则丢弃。如果后面跟了 bool 修饰符，则结果分别为 1 和 0。
- 向量与向量之间，运算过程类似于算术类操作符，只不过如果比较结果为真则保留左边的值（包括度量指标和标签这些属性），否则丢弃，没找到匹配也是丢弃。如果后面跟了 bool 修饰符，则保留和丢弃时结果相应为 1 和 0。

#### 逻辑类二元操作符

逻辑操作符仅用于向量与向量之间。

- and：交集
- or：合集
- unless：补集

具体运算规则如下：

- `vector1 and vector2` 的结果由在 vector2 里有匹配（标签键值对组合相同）元素的 vector1 里的元素组成。
- `vector1 or vector2` 的结果由所有 vector1 里的元素加上在 vector1 里没有匹配（标签键值对组合相同）元素的 vector2 里的元素组成。
- `vector1 unless vector2` 的结果由在 vector2 里没有匹配（标签键值对组合相同）元素的 vector1 里的元素组成。

#### 二元操作符优先级

PromQL 的各类二元操作符运算优先级如下：

1. ^
2. *, /, %
3. +, -
4. ==, !=, <=, <, >=, >
5. and, unless
6. or

### 向量匹配

前面算术类和比较类操作符都需要在向量之间进行匹配。共有两种匹配类型，`one-to-one` 和 `many-to-one` / `one-to-many`。

#### One-to-one 向量匹配

这种匹配模式下，两边向量里的元素如果其标签键值对组合相同则为匹配，并且只会有一个匹配元素。可以使用 `ignoring` 关键词来忽略不参与匹配的标签，或者使用 `on` 关键词来指定要参与匹配的标签。语法如下：

```
<vector expr> <bin-op> ignoring(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) <vector expr>
```

比如对于下面的输入：

```
method_code:http_errors:rate5m{method="get", code="500"}  24
method_code:http_errors:rate5m{method="get", code="404"}  30
method_code:http_errors:rate5m{method="put", code="501"}  3
method_code:http_errors:rate5m{method="post", code="500"} 6
method_code:http_errors:rate5m{method="post", code="404"} 21

method:http_requests:rate5m{method="get"}  600
method:http_requests:rate5m{method="del"}  34
method:http_requests:rate5m{method="post"} 120
```

执行下面的查询：

```
method_code:http_errors:rate5m{code="500"} / ignoring(code) method:http_requests:rate5m
```

得到的结果为：

```
{method="get"}  0.04            //  24 / 600
{method="post"} 0.05            //   6 / 120
```

也就是每一种 method 里 code 为 500 的请求数占总数的百分比。由于 method 为 put 和 del 的没有匹配元素所以没有出现在结果里。

#### Many-to-one / one-to-many 向量匹配

这种匹配模式下，某一边会有多个元素跟另一边的元素匹配。这时就需要使用 `group_left` 或 `group_right` 组修饰符来指明哪边匹配元素较多，左边多则用 group_left，右边多则用 group_right。其语法如下：

```
<vector expr> <bin-op> ignoring(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> ignoring(<label list>) group_right(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) group_right(<label list>) <vector expr>
```

> 组修饰符只适用于算术类和比较类操作符。

对于前面的输入，执行下面的查询：

```
method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m
```

将得到下面的结果：

```
{method="get", code="500"}  0.04            //  24 / 600
{method="get", code="404"}  0.05            //  30 / 600
{method="post", code="500"} 0.05            //   6 / 120
{method="post", code="404"} 0.175           //  21 / 120
```

也就是每种 method 的每种 code 错误次数占每种 method 请求数的比例。这里匹配的时候 ignoring 了 code，才使得两边可以形成 Many-to-one 形式的匹配。由于左边多，所以需要使用 group_left 来指明。

> Many-to-one / one-to-many 过于高级和复杂，要尽量避免使用。很多时候通过 ignoring 就可以解决问题。

### 聚合操作符

PromQL 的聚合操作符用来将向量里的元素聚合得更少。总共有下面这些聚合操作符：

- sum：求和
- min：最小值
- max：最大值
- avg：平均值
- stddev：标准差
- stdvar：方差
- count：元素个数
- count_values：等于某值的元素个数
- bottomk：最小的 k 个元素
- topk：最大的 k 个元素
- quantile：分位数

聚合操作符语法如下：

```
<aggr-op>([parameter,] <vector expression>) [without|by (<label list>)]
```

其中 `without` 用来指定不需要保留的标签（也就是这些标签的多个值会被聚合），而 `by` 正好相反，用来指定需要保留的标签（也就是按这些标签来聚合）。

下面来看几个示例：

```
sum(http_requests_total) without (instance)
```

http_requests_total 度量指标带有 application、instance 和 group 三个标签。上面的表达式会得到每个 application 的每个 group 在所有 instance 上的请求总数。效果等同于下面的表达式：

```
sum(http_requests_total) by (application, group)
```

下面的表达式可以得到所有 application 的所有 group 的所有 instance 的请求总数。

```
sum(http_requests_total)
```

## 函数

Prometheus 内置了一些函数来辅助计算，下面介绍一些典型的，完整的列表请参考 [官方文档](https://prometheus.io/docs/prometheus/latest/querying/functions/)。

- abs()：绝对值
- sqrt()：平方根
- exp()：指数计算
- ln()：自然对数
- ceil()：向上取整
- floor()：向下取整
- round()：四舍五入取整
- delta()：计算区间向量里每一个时序第一个和最后一个的差值
- sort()：排序
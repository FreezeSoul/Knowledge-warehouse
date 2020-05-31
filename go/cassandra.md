# cassandra

[TOC]

学习视频：

https://www.bilibili.com/video/BV1Ys411g7ij?from=search&seid=14814123987484833367

https://www.bilibili.com/video/BV1WJ411g7NK?from=search&seid=14814123987484833367



# Cassandra 架构



Cassandra的设计目的是处理跨多个节点的大数据工作负载，而没有任何单点故障。Cassandra在其节点之间具有对等分布式系统，并且数据分布在集群中的所有节点之间。

- 集群中的所有节点都扮演相同的角色。 每个节点是独立的，并且同时互连到其他节点。
- 集群中的每个节点都可以接受读取和写入请求，无论数据实际位于集群中的何处。
- 当节点关闭时，可以从网络中的其他节点提供读/写请求。

## Cassandra中的数据复制

在Cassandra中，集群中的一个或多个节点充当给定数据片段的副本。如果检测到一些节点以过期值响应，Cassandra将向客户端返回最近的值。返回最新的值后，Cassandra在后台执行读修复以更新失效值。

下图显示了Cassandra如何在集群中的节点之间使用数据复制，以确保没有单点故障的示意图。

![数据复制](https://atts.w3cschool.cn/attachments/tuploads/cassandra/data_replication.jpg)

**注** - Cassandra在后台使用Gossip协议，允许节点相互通信并检测集群中的任何故障节点。

## Cassandra的组件

Cassandra的关键组件如下：

- **节点** - 它是存储数据的地方。
- **数据中心** - 它是相关节点的集合。
- **集群** - 集群是包含一个或多个数据中心的组件。
- **提交日志** - 提交日志是Cassandra中的崩溃恢复机制。每个写操作都写入提交日志。
- ***\*Mem-\**表** - mem-表是存储器驻留的数据结构。提交日志后，数据将被写入mem表。有时，对于单列族，将有多个mem表。
- **SSTable** - 它是一个磁盘文件，当其内容达到阈值时，数据从mem表中刷新。
- **布隆过滤器** - 这些只是快速，非确定性的算法，用于测试元素是否是集合的成员。它是一种特殊的缓存。 每次查询后访问Bloom过滤器。

## Cassandra 查询语言

用户可以使用Cassandra查询语言（CQL）通过其节点访问Cassandra。CQL将数据库（Keyspace）视为表的容器。 程序员使用cqlsh：提示以使用CQL或单独的应用程序语言驱动程序。

客户端针对其读写操作访问任何节点。该节点（协调器）在客户端和保存数据的节点之间播放代理。

### 写操作

节点的每个写入活动都由写在节点中的提交日志捕获。稍后数据将被捕获并存储在存储器表中。每当内存表满时，数据将写入SStable数据文件。所有写入都会在整个集群中自动分区和复制。Cassandra会定期整合SSTables，丢弃不必要的数据。

### 读操作

在读操作，Cassandra 从MEM-表得到的值，并检查过滤器绽放找到保存所需数据的相应的SSTable。



## feature

- CQL
- 主键索引
- 二级索引, SASI
- 物化视图
- UDF/UDA
- 轻量级事务(CAS)
- 集合类型, counter
- CDC  (类似队列特性)
- TTL  （过期时间）
- Batch（事务）
- Online schema change  （修改schma 非阻塞）
















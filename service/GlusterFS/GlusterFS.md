**GlusterFS**

[TOC]

# GlusterFS 安装

**集群规划**

由3台主机组成GlusterFS集群，主机列表如下：

| 编号 | IP地址       | 主机名     |
| ---- | ------------ | ---------- |
| 1    | 192.168.0.20 | cdhserver1 |
| 2    | 192.168.0.21 | cdhserver2 |
| 3    | 192.168.0.22 | cdhserver3 |

**安装**

```
yum install centos-release-gluster
yum install glusterfs glusterfs-fuse glusterfs-server
```

**启动**

```
systemctl start glusterfsd
systemctl enable glusterfsd
```

**组建集群**

在 cdhserver1 上执行以下命令

```
gluster peer probe 192.168.0.21
gluster peer probe 192.168.0.22
```

**集群验证**

```
gluster peer 
detach  probe   status  
[root@cdhserver1 flannel]# gluster peer status 
Number of Peers: 2

Hostname: cdhserver3
Uuid: 5b3864a8-0bfe-4ee2-94e1-4d03b6cf8a72
State: Peer in Cluster (Connected)

Hostname: cdhserver2
Uuid: ebc7627e-1adf-419e-8be8-601e97c1d4e7
State: Peer in Cluster (Connected)
```

# 创建共享磁盘

**创建文件夹**

在每台服务器上创建文件夹`mkdir -p /bricks/vol2`

```
mkdir -p /bricks/vol2
```

**创建共享盘**

````
gluster volume create vol2 replica 3 cdhserver1:/bricks/vol2  cdhserver2:/bricks/vol2 cdhserver3:/bricks/vol2 force
````

**启动共享盘**

```
gluster volume start vol2
```

**查看信息**

```
# gluster volume list
vol1
vol2
# gluster volume info vol2
 
Volume Name: vol2
Type: Replicate
Volume ID: b7f51a80-1d8a-4fb1-8653-6a61af1cd190
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: cdhserver1:/bricks/vol2
Brick2: cdhserver2:/bricks/vol2
Brick3: cdhserver3:/bricks/vol2
Options Reconfigured:
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
```



# Heketi 部署

```
https://github.com/gluster/gluster-kubernetes/
```




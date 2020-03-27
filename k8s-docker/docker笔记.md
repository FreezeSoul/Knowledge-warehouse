## docker 简介

Docker 虚拟化技术基于内核Cgroup 和 Namespace

Docker 并不会直接与内核交互 通过Libcontainer 与内核交互。

层级镜像，不同的容器可以共享底层的制度镜像。

## Docker组件

- Docker 客户端
- Docker darmon
- Docker 容器
- Docker 镜像
- Registry

## 容器的组成

> 容器=cgroup + namespace + rootfs + 容器引擎(用户态工具)

功能：

- cgroup：资源控制
- namespace：资源隔离
- rootfs：文件系统隔离
- 容器引擎：生命周期控制

## Cgroup介绍

Cgroup 是 control group 的简写，属于Linux内核提供的一个特性，用于限制和隔离一组进程对系统资源的使用，也就是做资源Qos，这些资源包涵CPU、内存、blockI/O 和 网络带宽。

截止到内核4.1 Cgroup中实现的子系统及其作用如下：

- devices：设备权限控制
- cpuset：分配指定的cpu和内存节点
- cpu：控制CPU占用率
- cpuacct：统计CPU使用情况
- memory：限制内存的使用上限
- freezer：冻结（暂停）Cgroup 中的进程
- net_cls：配合tc（traffic controller）限制网络带宽
- net_prio：设置进程的网络流量优先级
- huge_tlb：限制hugeTLB的使用
- perf_event：允许Perf工具基于Cgroup分组做性能监测 

### Cgroup 子系统介绍

**1.cpuset 子系统**

为一组进程分配指定的CPU和内存节点。

- cpuset.cpus：允许进程使用的CPU列表
- cpuset.mems：允许进程使用的内存节点列表

**2.cpu子系统**

cpu子系统用于限制进程的CPU占用率，三个功能

- CPU比重分配：由cpu.shares提供特性。
- CPU带宽限制:  cpu.rt_period_us 和 cpu.cfs_quota_us 这两个接口的单位是微妙。可以将period设置为1秒，将quota设置为0.5秒，那么Cgroup中的进程在1秒内最多运行0.5秒，然后就会被强制睡眠。
- 实时进程的CPU带宽限制。cpu.rt_period_us 和 cpu.rt_runtime_us。

**3.cpuacct 子系统**

cpuacct 用来统计各个Cgroup的CPU使用情况

**4.memory子系统**

memory 子系统用来限制Cgroup所能使用的内存上限。

**5.blkio 子系统**

blkio 子系统用来限制Cgroup 的block I/O带宽。

**6.devices子系统**

用来控制Cgroup 的进程对那些设备有访问权限

## Namespace 

​	Namespace 是将内核的全局资源做封装，使得每个Namespace都有一份独立的资源，因此不同的进程在各自的Namespace内对同一种资源的使用不会互相干扰。

目前Linux内核的6种Namespace：

- IPC：隔离System VIPC和 POSIX 消息对列
- Network：隔离网络资源
- Mount：隔离文件系统挂载点
- PID：隔离进程id
- UTS：隔离主机名和域名
- User：隔离用户ID和组ID

### Namespace的接口和使用

对Namespace 的操作 主要通过 clone setns 和unshare 这3个系统调用来完成。


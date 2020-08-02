# 04-Docker虚拟化网络概述

[TOC]

## docker 虚拟化网络概述

1. OVS: OpenVSwitch,不仅能模拟二层网络，还能模拟三层网络，或者VLAN，VXLAN,流控 SDN软件定义网络技术等。
2. overlay network ：叠加网络
3. docker 安装后默认会有三种网络。

```
[root@localhost yum.repos.d]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
e0b61e87623d        bridge              bridge              local
1f98da302a92        host                host                local
bdb9eff6069c        none                null                local
```

4. docker 安装后自动会创建一个软交换机docker0，他既可以扮演二层的交换设备也可以扮演二层的网卡设备，不给地址的话就是交换机，给地址的话既能当交换机又能当网卡。每当创建一个容器的时候就会创建一段网卡，一半连到容器上一半连到宿主机上，并且关联到了docker0，相当于用一根网线连接了容器和软交换机docker0，使用bridge-utils工具可以查看到

```
[root@localhost /]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
9344abfbcbd6        centos              "/bin/bash"         12 seconds ago      Up 12 seconds                           test_centos2
9bd5c09f2a2c        centos              "/bin/bash"         20 seconds ago      Up 19 seconds                           test_centos1
[root@localhost /]# brctl show
bridge name    bridge id        STP enabled    interfaces
docker0        8000.0242a13c61e1    no        veth1889d70
                            veth55b0650
[root@localhost /]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:a7:ce:04 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.46/24 brd 192.168.10.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::2b2a:bd85:8d15:14c/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:a1:3c:61:e1 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:a1ff:fe3c:61e1/64 scope link 
       valid_lft forever preferred_lft forever
7: veth55b0650@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether 1a:4a:bd:27:e9:94 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::184a:bdff:fe27:e994/64 scope link 
       valid_lft forever preferred_lft forever
9: veth1889d70@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether 16:5e:42:f3:de:81 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::145e:42ff:fef3:de81/64 scope link 
       valid_lft forever preferred_lft forever
[root@localhost /]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 00:0c:29:a7:ce:04 brd ff:ff:ff:ff:ff:ff
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
    link/ether 02:42:a1:3c:61:e1 brd ff:ff:ff:ff:ff:ff
7: veth55b0650@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT group default 
    link/ether 1a:4a:bd:27:e9:94 brd ff:ff:ff:ff:ff:ff link-netnsid 1
9: veth1889d70@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT group default 
    link/ether 16:5e:42:f3:de:81 brd ff:ff:ff:ff:ff:ff link-netnsid 2
```

5. 每当创建一个容器并分配地址以后，就会在物理主机上生成一个iptables规则。
6. docker有四种网络模型，若在容器创建时没有指定那么通通默认为第二种网络，桥接式网络，并且这个是nat桥不是物理桥。
   - closed container封闭式容器，只有回环口。
   - brdged container 桥接式容器，有虚拟网卡，连接到docker网桥上，默认网络地址为172.17.0.0/16  
   - joined container 联盟式容器，让容器一部分名称空间是隔离的。
   - open container 开放式容器，和物理机共享名称空间
# 05-Docker容器网络

[TOC]

## 内核网络名称空间

### 可通过ip netns进行操作

```
[root@localhost /]# ip netns help
Usage: ip netns list
       ip netns add NAME
       ip netns set NAME NETNSID
       ip [-all] netns delete [NAME]
       ip netns identify [PID]
       ip netns pids NAME
       ip [-all] netns exec [NAME] cmd ...
       ip netns monitor
       ip netns list-id
```

### 启动各种网络类型的容器

- 启动一个网络类型为bridge的容器并且在退出后自动删除(即能够对外通信的容器)。

```
[root@localhost ~]# docker run --name t1 -it --network bridge --rm busybox:latest
/ # ifconfig 
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:04  
          inet addr:172.17.0.4  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:508 (508.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

   - 启动一个网络类型为none的容器并且在退出后自动删除(即封闭式容器)

```
[root@localhost ~]# docker run --name t1 -it --network none --rm busybox:latest
/ # ifconfig 
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

/ # exit
```
   -  容器默认的主机名就是其id，也可以在启动的时候给上主机名
```
[root@localhost ~]# docker run --name t1 -it --network bridge -h wohaoshuai --rm busybox:latest
/ # hostname 
wohaoshuai
```
   -  容器默认的dns是宿主机的dns，可以在启动的时候给上其dns
```
[root@localhost ~]# docker run --name t1 -it --network bridge -h wohaoshuai --dns 114.114.114.114 --rm busybox:latest
/ # cat /etc/hosts 
127.0.0.1    localhost
::1    localhost ip6-localhost ip6-loopback
fe00::0    ip6-localnet
ff00::0    ip6-mcastprefix
ff02::1    ip6-allnodes
ff02::2    ip6-allrouters
172.17.0.4    wohaoshuai
/ # cat /etc/resolv.conf 
nameserver 114.114.114.114
```
   - 可以给主机添加主机解析记录
```
[root@localhost ~]# docker run --name t1 -it --network bridge -h wohaoshuai --dns 114.114.114.114 --add-host www.wohaoshuai.com:192.168.11.11 --rm busybox:latest
/ # cat /etc/hosts 
127.0.0.1    localhost
::1    localhost ip6-localhost ip6-loopback
fe00::0    ip6-localnet
ff00::0    ip6-mcastprefix
ff02::1    ip6-allnodes
ff02::2    ip6-allrouters
192.168.11.11    www.wohaoshuai.com
172.17.0.4    wohaoshuai
```
### 端口映射　-p

- 将指定的容器端口映射至主机所有地址的一个动态端口

```
[root@localhost ~]# docker run -it -p 80 --rm --name webtest1 httpd 
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
[Sat Apr 13 10:59:16.001251 2019] [mpm_event:notice] [pid 1:tid 140311487656000] AH00489: Apache/2.4.39 (Unix) configured -- resuming normal operations
[Sat Apr 13 10:59:16.001475 2019] [core:notice] [pid 1:tid 140311487656000] AH00094: Command line: 'httpd -D FOREGROUND'
192.168.10.1 - - [13/Apr/2019:10:59:57 +0000] "GET / HTTP/1.1" 200 45
192.168.10.1 - - [13/Apr/2019:10:59:57 +0000] "GET /favicon.ico HTTP/1.1" 404 209
另开一个shell查看：
[root@localhost ~]# docker port webtest1 
80/tcp -> 0.0.0.0:32768
```
   - 将容器端口映射至指定的主机端口
```
[root@localhost ~]# docker run -it --rm  -p 80:80 --name webtest1 httpd 
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
[Sat Apr 13 11:05:43.973155 2019] [mpm_event:notice] [pid 1:tid 140421815427136] AH00489: Apache/2.4.39 (Unix) configured -- resuming normal operations
[Sat Apr 13 11:05:43.973377 2019] [core:notice] [pid 1:tid 140421815427136] AH00094: Command line: 'httpd -D FOREGROUND'

另起一个shell查看：
[root@localhost ~]# docker port webtest1 
80/tcp -> 0.0.0.0:80
```
   - 将指定的容器端口映射至主机指定ip的动态端口
```
[root@localhost ~]# docker run -it --rm  -p 192.168.10.46::80 --name webtest1 httpd 
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
[Sat Apr 13 11:10:08.815379 2019] [mpm_event:notice] [pid 1:tid 140160940060736] AH00489: Apache/2.4.39 (Unix) configured -- resuming normal operations
[Sat Apr 13 11:10:08.815558 2019] [core:notice] [pid 1:tid 140160940060736] AH00094: Command line: 'httpd -D FOREGROUND'

另开一个shell查看：
[root@localhost ~]# docker port webtest1 
80/tcp -> 192.168.10.46:32769
```
   - 将指定的容器端口映射至主机指定的ip 的端口
```
[root@localhost ~]# docker run -it --rm  -p 192.168.10.46:80:80 --name webtest1 httpd 
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
[Sat Apr 13 11:11:47.699843 2019] [mpm_event:notice] [pid 1:tid 139789685690432] AH00489: Apache/2.4.39 (Unix) configured -- resuming normal operations
[Sat Apr 13 11:11:47.699977 2019] [core:notice] [pid 1:tid 139789685690432] AH00094: Command line: 'httpd -D FOREGROUND'
192.168.10.1 - - [13/Apr/2019:11:11:55 +0000] "GET / HTTP/1.1" 200 45
192.168.10.1 - - [13/Apr/2019:11:11:56 +0000] "GET /favicon.ico HTTP/1.1" 404 209

[root@localhost ~]# docker port webtest1 
80/tcp -> 192.168.10.46:80
```
### 暴露容器所有端口到宿主机 -P

### 启动联盟式容器

- 启动容器1

```
[root@localhost ~]# docker run -it --name b1 --rm busybox
/ # ifconfig 
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:04  
          inet addr:172.17.0.4  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:578 (578.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

- 启动容器2共享容器1的网络名称空间（但是文件系统不是共享的）

```
[root@localhost ~]# docker run -it --name b2 --network container:b1 --rm busybox
/ # ifconfig 
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:04  
          inet addr:172.17.0.4  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:648 (648.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

- 在容器1上启动一个httpd服务

```
/ # mkdir /tmp/httptest
/ # echo "http test" >> /tmp/httptest/index.html
/ # httpd -h /tmp/httptest/
/ # netstat -anpt
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address Foreign Address State PID/Program name
tcp 0 0 :::80 :::* LISTEN 9/httpd
tcp 0 0 ::ffff:127.0.0.1:80 ::ffff:127.0.0.1:33282 TIME_WAIT -
```

- 在容器2上查看

```
/ # wget -O - -q 127.0.0.1
http test
/ # netstat -anpt
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 :::80                   :::*                    LISTEN      -
```

### 共享主机网络空间

- 启动容器2，共享主机网络空间

```
[root@localhost ~]# docker run -it --name b2 --network host --rm busybox
/ # ifconfig 
docker0   Link encap:Ethernet  HWaddr 02:42:07:6B:46:88  
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:7ff:fe6b:4688/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:31 errors:0 dropped:0 overruns:0 frame:0
          TX packets:44 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:3044 (2.9 KiB)  TX bytes:4258 (4.1 KiB)

ens33     Link encap:Ethernet  HWaddr 00:0C:29:A7:CE:04  
          inet addr:192.168.10.46  Bcast:192.168.10.255  Mask:255.255.255.0
          inet6 addr: fe80::2b2a:bd85:8d15:14c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:45436 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11563 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:54165413 (51.6 MiB)  TX bytes:1167461 (1.1 MiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:48 errors:0 dropped:0 overruns:0 frame:0
          TX packets:48 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:5280 (5.1 KiB)  TX bytes:5280 (5.1 KiB)

veth24abfad Link encap:Ethernet  HWaddr 82:21:2D:BA:ED:63  
          inet6 addr: fe80::8021:2dff:feba:ed63/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:22 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:1576 (1.5 KiB)

veth34dd4fe Link encap:Ethernet  HWaddr EA:F1:6D:7E:EB:23  
          inet6 addr: fe80::e8f1:6dff:fe7e:eb23/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:648 (648.0 B)

vetha7c5640 Link encap:Ethernet  HWaddr CE:76:19:9D:AE:0E  
          inet6 addr: fe80::cc76:19ff:fe9d:ae0e/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:24 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:1744 (1.7 KiB)
```

- 在容器中启动http服务，在宿主机中也可访问

```
/ # echo "hello wohaoshuai" > /tmp/index.html
/ # httpd -h /tmp/
/ # 
/ # 
/ # 
/ # netstat -anpt
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      -
tcp        0      0 192.168.10.46:22        192.168.10.1:50937      ESTABLISHED -
tcp        0     52 192.168.10.46:22        192.168.10.1:51766      ESTABLISHED -
tcp        0      0 :::111                  :::*                    LISTEN      -
tcp        0      0 :::80                   :::*                    LISTEN      8/httpd
tcp        0      0 :::22                   :::*                    LISTEN      -
tcp        0      0 ::1:25                  :::*                    LISTEN      -
```

## 修改docker 默认项

### 自定义docker网络属性

```
[root@localhost ~]# more /etc/docker/daemon.json 
{
  "registry-mirrors": ["https://guxaj7v7.mirror.aliyuncs.com","https://registry.docker-cn.com"],
  "bip": "10.0.0.1/16"
}
[root@localhost ~]# ip addr
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
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:07:6b:46:88 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.1/16 brd 10.0.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:7ff:fe6b:4688/64 scope link 
       valid_lft forever preferred_lft forever
```

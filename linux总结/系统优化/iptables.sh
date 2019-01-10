#########################################################################
# File name: "iptables.sh"
# Author: huruizhi
# mail: 510543763@qq.com
# Created Time: 2019-01-10
#########################################################################
#!/bin/bash

INTERNET="eth0"
LOOPBACK_INTERFACE="lo"
IPADDR="my.ip.address"
SUBNET_BASE="my.subnet.network"
SUBNET_BROADCAST="my.subnet.bcast"
LOOPBACK="127.0.0.0/8"
CLASS_A="10.0.0.0/8"
CLASS_B="172.16.0.0/12"
CLASS_C="192.168.0.0/16"
CLASS_D_MUTICAST="224.0.0.0/4"
CLASS_E_RESERVED_NET="240.0.0.0/5"
BROADCAST_SRC="0.0.0.0"
BROADCAST_DEST="255.255.255.255"
PRIVPORTS="0:1023"
UNPRIVPORTS="1024:65535"
IPT="/sbin/iptables"

[ $UID -eq 0 ]||{
echo "Plz run as root!"
exit 1
}

function install_iptables(){
echo "安装iptbales"
yum install iptables-services -y

# 开启iptables
systemctl enable iptables
systemctl restart iptables

}

function core(){
echo -n "启动内核对监控的支持"

# 丢弃组播ping包
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# 丢弃源路由数据包
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route 

# 开启SYN cookies
echo "1" > /proc/sys/net/ipv4/tcp_syncookies 

# 禁用重定向
echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects 
echo "0" > /proc/sys/net/ipv4/conf/all/send_redirects 

# 防止原地址攻击
for f in /proc/sys/net/ipv4/conf/*/rp_filter
do
	echo "1" >$f
done

# 记录不太可能的地址的数据包
echo "1" > /proc/sys/net/ipv4/conf/all/log_martians 

sleep 1
echo "...finished!"
}


function iptables_init(){
echo -n "初始化iptables"
$IPT --flush
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

$IPT --policy INPUT ACCEPT
$IPT --policy OUTPUT ACCEPT
$IPT --policy FORWARD ACCEPT

$IPT -t nat --policy PREROUTING ACCEPT
$IPT -t nat --policy OUTPUT ACCEPT
$IPT -t nat --policy POSTROUTING ACCEPT

$IPT -t mangle --policy PREROUTING ACCEPT
$IPT -t mangle --policy OUTPUT ACCEPT
sleep 1
echo "...finished!"

echo -n "启动还回口"
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
sleep 1
echo "...finished!"

}



function iptables_filters(){
echo -n "定义默认策略"
$IPT --policy INPUT DROP
$IPT --policy OUTPUT ACCEPT
$IPT --policy FORWARD DROP

sleep 1
echo "...finished!"

echo -n "开启状态监测"
# 静态规则与动态规则必须同时使用
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

$IPT -A OUTPUT -m state --state INVALID -j LOG --log-prefix "INVALID input: "
$IPT -A OUTPUT -m state --state INVALID -j DROP
$IPT -A OUTPUT -m state --state INVALID -j LOG --log-prefix "INVALID input: "
$IPT -A OUTPUT -m state --state INVALID -j DROP

sleep 1
echo "...finished!"

echo -n "源地址欺骗及其他不合法地址"
$IPT -A INPUT -i $INTERNET -s $IPADDR -j DROP
# $IPT -A INPUT -i $INTERNET -s $CLASS_A -j DROP
# $IPT -A INPUT -i $INTERNET -s $CLASS_B -j DROP
# $IPT -A INPUT -i $INTERNET -s $CLASS_C -j DROP
$IPT -A INPUT -i $INTERNET -s $LOOPBACK -j DROP

$IPT -A INPUT -i $INTERNET -s $BROADCAST_SRC -j LOG
$IPT -A INPUT -i $INTERNET -s $BROADCAST_SRC -j DROP
$IPT -A INPUT -i $INTERNET -s $BROADCAST_DEST -j  LOG
$IPT -A INPUT -i $INTERNET -s $BROADCAST_DEST -j  DROP



$IPT -A INPUT -i $INTERNET -s $SUBNET_BASE -j DROP
$IPT -A INPUT -i $INTERNET -s $SUBNET_BROADCAST -j DROP

$IPT -A INPUT -i $INTERNET -s $CLASS_D_MUTICAST -j DROP
$IPT -A INPUT -i $INTERNET -s $CLASS_E_RESERVED_NET -j DROP

sleep 1
echo "...finished!"

echo -n "开启ssh 与icmp"

$IPT -A INPUT -i $INTERNET  -p tcp -d $IPADDR --dport 22 -j ACCEPT
$IPT -A INPUT -i $INTERNET  -p icmp -d $IPADDR -j ACCEPT
sleep 1
echo "...finished!"

service iptables save >/dev/null

}



function add_filter(){
echo "添加允许访问的服务："
while [ 1 == 1 ]
do
	read -p "protocol [t]cp/[u]dp: "  protocol
	case $protocol in
	"t"|"T")
			protocol="tcp"
			break
			;;
	"u"|"U")
			protocol="udp"
			break
			;;	
	esac
done

while [ 1 == 1 ]
do
	read -p "port: "  dport
	dport=${dport:-a}
	[ -z "${dport//[0-9]/}"  ]&&[ $dport -le 65535 ]&&break 
	echo "输入错误，端口号必须满足 1. 整数 2. 0-65535 之间"
done

$IPT -A INPUT -i $INTERNET  -p $protocol -d $IPADDR --dport $dport -j ACCEPT
[ $? -eq 0 ]&& service iptables save >/dev/null&& echo "规则添加成功！"
}


function init(){
# 关闭firewall
systemctl stop firewalld.service
systemctl disable firewalld.service

systemctl restart iptables >/dev/null 2>&1
[ $? -eq 0 ]&&echo "重启iptables"||install_iptables

read -p "本机IP地址网段：" SUBNET_BASE
read -p "本机IP地址网络广播地址：" SUBNET_BROADCAST

core
iptables_init
iptables_filters
}

function main(){
read -p "本机IP地址：" IPADDR
while [ 1 == 1 ]
do
	cat<<-EOF
	请选择以下操作:
	1. 初始化防火墙
	2. 添加所有监听的端口
	3. 添加防火墙规则
	4. 打印规则
	5. 退出
	EOF
	read -p "选择：" c
	case $c in
	"1")
		init
		;;
	"2")
		ss -lntup|awk '{if(NR>1){print $1":"$5}}'|awk -v IPT=$IPT -v INTERNET=$INTERNET -v IPADDR=$IPADDR -F ":" '{print IPT" -A INPUT -i "INTERNET"  -p "$1" -d "IPADDR" --dport "$NF" -j ACCEPT"}'|sort |uniq|bash
		service iptables save >/dev/nul
		[ $? -eq 0 ]&&echo "端口添加成功！"
		;;
	"3")
		add_filter
		;;
	"4")
		$IPT -L
		;;
	"5")
		echo "退出操作"
		exit 1
		;;
	*)
	  clear
		;;
	esac
done
}


main

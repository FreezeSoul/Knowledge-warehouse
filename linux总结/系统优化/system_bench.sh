#!/bin/bash
# created py huruizhi


[ -f /etc/redhat-release ]||{
echo "run this program on Ceontos"
exit 1
}


[ $UID -eq 0 ]||{
echo "plz run as supueruser!"
exit 2
}

sysbench --version >/dev/null 2>&1
[ $? -eq 0 ]||{
echo -e "\033[32m安装sysbench\033[0m"
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum -y install sysbench
}

[ $? -eq 0 ]&& sysbench_version=$(sysbench --version)||{
	echo "sysbench 安装失败"
	exit 3
}


main_menu(){
clear
cat<<EOF
sysbench 基准测试工具
$sysbench_version  
测试项目:

1. 磁盘io测试
2. 内存测试
3. CPU测试
4. Mysql 数据库测试

==========
注意: io测试至少需要 150G 的剩余空间。
EOF
}

io_test(){
	process_num=`cat /proc/cpuinfo |grep process|wc -l`
	echo -e "\033[32m1. 准备测试环境\033[0m"
	sysbench fileio  cleanup
	sysbench fileio --file-total-size=150G --file-num=20 prepare
	echo -e "\033[32m环境准备完毕\033[0m"
	echo -e "\033[32m3. 顺序读 测试\033[0m"
	sysbench fileio --file-total-size=150G --file-test-mode=seqrd --file-num=20 --time=300 --max-requests=0 --threads=${process_num} run|grep "File operations:" -A 8
	echo  -e "\033[32m5. 随机读 测试\033[0m"
	sysbench fileio --file-total-size=150G --file-test-mode=rndrd --file-num=20 --time=300 --max-requests=0 --threads=${process_num} run|grep "File operations:" -A 8
	echo -e "\033[32m2. 顺序写 测试\033[0m"
	sysbench fileio --file-total-size=150G --file-test-mode=seqwr --file-num=20 --time=300 --max-requests=0 --threads=${process_num} run|grep "File operations:" -A 8
	echo  -e "\033[32m4. 随机写 测试\033[0m"
	sysbench fileio --file-total-size=150G --file-test-mode=rndwr --file-num=20 --time=300 --max-requests=0 --threads=${process_num} run|grep "File operations:" -A 8
	echo -e "\033[32m清除测试数据\033[0m"
	sysbench fileio cleanup

}

mem_test(){
	echo -e "\033[32m开始内存性能测试\033[0m"
	echo -e "\033[32m内存 顺序写 测试\033[0m"
	sysbench memory --memory-oper=write --memory-access-mode=seq --time=30 run|grep "Total operations:" -A 3
	echo -e "\033[32m内存 顺序读 测试\033[0m"
	sysbench memory --memory-oper=read --memory-access-mode=seq --time=30 run|grep "Total operations:" -A 3
	echo -e "\033[32m内存 随机写 测试\033[0m"
	sysbench memory --memory-oper=write --memory-access-mode=rnd --time=30 run|grep "Total operations:" -A 3
	echo -e "\033[32m内存 随机读 测试\033[0m"
	sysbench memory --memory-oper=read --memory-access-mode=rnd --time=30 run|grep "Total operations:" -A 3
}


cpu_test(){
	process_num=`cat /proc/cpuinfo |grep process|wc -l`
	echo -e "\033[32m开始 CPU 性能测试 cpu线程数量: ${process_num}\033[0m"
	sysbench cpu --cpu-max-prime=20000 --threads=${process_num} run |grep "CPU speed:" -A 6
}

mysql_test(){
	clear
	echo "数据库测试 确保数据库中存在sbtest库，且测试账号拥有权限。”
	echo “请输入数据库连接信息"
	base_dir='/usr/share/sysbench/'
	read -p "数据库用户名:" username
	read -sp "数据库密码:" passwd
	echo ""
	while [ 1 -eq 1 ]
		do
			read -p "请选择mysql 连接方式[socket|host]:" connect
			case "$connect" in
			"socket")
				read -p "请输入数据库socket文件路径:" connect_way
				[ -S $connect_way ]&& connect_str="--mysql-host=${connect_way}";break || echo -e "\033[31msocket 文件路径不存在 或 不是一个socket文件！\033[0m"
				;;
			"host")
				read -p "请输入数据库IP地址/域名:" connect_way
				ping $connect_way -c 1 -w 5 >/dev/null 2>&1
				[ $? -eq 0 ]&& connect_str="--mysql-host=${connect_way}";break || echo -e "\033[31m网络地址无法到达\033[0m"	
			
			esac
	
	echo "数据库准备"
	sysbench /usr/share/sysbench/oltp_read_only.lua --threads=4  --mysql-user=pycf --mysql-password=1qaz@WSXabc --mysql-port=3320 --tables=10 --table-size=1000000 prepare
 
	done
	


}


main(){
main_menu
read -p "请选择测试内容:" num
case "$num" in
"1")
	io_test
	;;
"2")
	mem_test
	;;
"3")
	cpu_test
	;;
"4")
	mysql_test
	;;
*)
	echo "plz input num in 1-4"
	;;
esac

}

main

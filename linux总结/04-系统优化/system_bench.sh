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

1. 系统测试
2. Mysql 数据库测试

==========
EOF
}

system_menu(){
clear
cat<<EOF
系统测试项目:

1. 磁盘io测试
2. 内存测试
3. CPU测试

==========
注意: io测试至少需要 150G 的剩余空间。
EOF
read -p " 请选择测试内容:" num
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
	"*")
		echo "input error"

esac

}

io_test(){
	process_num=`cat /proc/cpuinfo |grep process|wc -l`
	echo -e "\033[32m1. 准备测试环境\033[0m"
	sysbench fileio  cleanup
	sysbench fileio --file-total-size=150G --file-num=20 prepare
	echo -e "\033[32m环境准备完毕\033[0m"
	echo -e "\033[32m3. 顺序读 测试\033[0m"
	sysbench fileio --file-total-size=150G --file-test-mode=seqrd --file-num=20 --time=300 --max-requests=0 --threads=${process_num} --report-interval=30 run
	echo  -e "\033[32m5. 随机读 测试\033[0m"
	sysbench fileio --file-total-size=150G --file-test-mode=rndrd --file-num=20 --time=300 --max-requests=0 --threads=${process_num} --report-interval=30 run
	echo -e "\033[32m2. 顺序写 测试\033[0m"
	sysbench fileio --file-total-size=150G --file-test-mode=seqwr --file-num=20 --time=300 --max-requests=0 --threads=${process_num} --report-interval=30 run
	echo  -e "\033[32m4. 随机写 测试\033[0m"
	sysbench fileio --file-total-size=150G --file-test-mode=rndwr --file-num=20 --time=300 --max-requests=0 --threads=${process_num} --report-interval=30 run
	echo -e "\033[32m清除测试数据\033[0m"
	sysbench fileio cleanup

}

mem_test(){
	echo -e "\033[32m开始内存性能测试\033[0m"
	echo -e "\033[32m内存 顺序写 测试\033[0m"
	sysbench memory --memory-oper=write --memory-access-mode=seq --report-interval=10 --time=30 run
	echo -e "\033[32m内存 顺序读 测试\033[0m"
	sysbench memory --memory-oper=read --memory-access-mode=seq --report-interval=10 --time=30 run
	echo -e "\033[32m内存 随机写 测试\033[0m"
	sysbench memory --memory-oper=write --memory-access-mode=rnd --report-interval=10  --time=30 run
	echo -e "\033[32m内存 随机读 测试\033[0m"
	sysbench memory --memory-oper=read --memory-access-mode=rnd  --report-interval=10 --time=30 run
}


cpu_test(){
	process_num=`cat /proc/cpuinfo |grep process|wc -l`
	echo -e "\033[32m开始 CPU 性能测试 cpu线程数量: ${process_num}\033[0m"
	sysbench cpu --cpu-max-prime=20000 --threads=${process_num} --report-interval=10 run 
}

mysql_test(){
	clear
	echo -ne "数据库测试 \033[31m确保数据库中存在sbtest库，且测试账号拥有权限。\033[0m"
	while [ 1 -eq 1 ]
	do
		read -p "数据库准备是否OK ?(Y)是 (N)否 [Y]" prepare
		case "${prepare:-Y}" in
		      	"N"|"n")  
				exit 0
				;;
			"Y"|"y")
				break
				;;
	
			*)
				echo "输入错误！"
				;;
		esac	
	done

	base_dir='/usr/share/sysbench'
	while [ 1 -eq 1 ]
	do
		echo "请输入数据库连接信息"
		
		while [ 1 -eq 1 ]
		do
			read -p "请选择mysql 连接方式 (S)ocket (H)ost :" connect
			case "$connect" in
			"S"|"s")
				read -p "请输入数据库socket文件路径:" connect_way
				[ -S $connect_way ]&& connect_str="--mysql-socket=${connect_way}";break || echo -e "\033[31msocket 文件路径不存在 或 不是一个socket文件！\033[0m"
				;;
			"H"|"h")
				read -p "请输入数据库IP地址/域名 [127.0.0.1]:" connect_way
				read -p "请输入数据库端口: [3306]" port
				connect_way=${connect_way:-127.0.0.1}
				port=${port:-3306}
				ping $connect_way -c 1 -w 5 >/dev/null 2>&1
				[ $? -eq 0 ]&&{
connect_str="--mysql-host=${connect_way} --mysql-port=${port}"
break
}|| echo -e "\033[31m网络地址无法到达\033[0m"	
				;;
			esac
		done

		read -p "数据库用户名:" username
		read -sp "数据库密码:" passwd
		echo ""
		echo -e "\033[32m开始准备测试数据库\033[0m"
		sysbench ${base_dir}/oltp_read_only.lua --threads=4  --mysql-user=${username} --mysql-password=${passwd} ${connect_str} --tables=10 --table-size=1000000 prepare
	 	[ $? -eq 0 ]&&{
echo -e "\033[32m测试准备完成\033[0m"
break
}||echo -e "\033[31m数据库准备失败\033[0m"
		sleep 3 
	done

	while [ 1 -eq 1 ]
	do
	cat <<-EOF
	请选择测试内容
	1.数据库读性能测试
	2.数据库读写性能测试
	3.数据库写性能测试
	4.退出
	EOF
	
	echo -ne "\033[32m选择测试项目: \033[0m"
	read select_num
	case  "$select_num" in
		"1")
			sysbench /usr/share/sysbench/oltp_write_only.lua --threads=16 --events=0  --time=300  --mysql-user=${username} --mysql-password=${passwd} ${connect_str} --tables=10 --table-size=1000000 --range_selects=on --report-interval=10 run 
			;;
		"2")
			sysbench /usr/share/sysbench/oltp_read_write.lua --threads=16 --events=0  --time=300  --mysql-user=${username} --mysql-password=${passwd} ${connect_str} --tables=10 --table-size=1000000 --range_selects=on --report-interval=10 run 
			;;
		"3")
			sysbench /usr/share/sysbench/oltp_read_write.lua --threads=16 --events=0  --time=300  --mysql-user=${username} --mysql-password=${passwd} ${connect_str} --tables=10 --table-size=1000000 --range_selects=on --report-interval=10 run 
			;;
		"4")
			sysbench ${base_dir}/oltp_read_only.lua --threads=4  --mysql-user=${username} --mysql-password=${passwd} ${connect_str} --tables=10 --table-size=1000000 cleanup
			exit 0
			;;
		*)
			echo -e "\033[31m请输入正确的测试项目编号\033[0m"
			;;
	esac
	done

}


main(){
main_menu
read -p "请选择测试内容:" num
case "$num" in
"1")
	system_menu
	;;
"2")
	mysql_test
	;;
*)
	echo "input error"
	;;
esac

}

main

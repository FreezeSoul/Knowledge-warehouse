## mycat

数据库中间件 实现读写分离

- 读写分离
- 双主双从

数据分片

- 垂直分库
- 水平分表

多数据源整合

整合 noSQL mySQL 等

### mycat 安装部署

#### 1.下载与部署

下载地址  http://dl.mycat.io/1.6-RELEASE/

#### 2.主要配置文件

schema.xml   定义逻辑库 表 分片节点内容

rule.xml         定义分片规则

server.xml         定义用户及系统相关变量 如端口等i

1. 修改server.xml

   修改 80 行

```
 80         <user name="Mycat">
 81                 <property name="password">123456</property>
 82                 <property name="schemas">TESTDB</property>   
 83 
 84                 <!-- 表级 DML 权限设置 -->
 85                 <!--            
 86                 <privileges check="false">
 87                         <schema name="TESTDB" dml="0110" >
 88                                 <table name="tb01" dml="0000"></table>
 89                                 <table name="tb02" dml="1111"></table>
 90                         </schema>
 91                 </privileges>           
 92                  -->
 93         </user>
```

> <property name="schemas">TESTDB</property>  TESTDB 为mycat 逻辑库的库名

2. 修改 schema.xml

```
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">

        <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="102" dataNode="dn1">
        </schema>
        <dataNode name="dn1" dataHost="localhost1" database="testdb" />
        <dataHost name="localhost1" maxCon="1000" minCon="10" balance="0"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <!-- can have multi write hosts -->
                <writeHost host="hostM1" url="10.60.20.104:3306" user="root"
                                   password="123456">
                        <!-- can have multi read hosts -->
                        <readHost host="hostS2" url="10.60.20.105:3306" user="root" password="xxx" />
                </writeHost>
        </dataHost>
</mycat:schema>
```

配置说明

```
<schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="102" dataNode="dn1">
// mycat 虚拟库的配置  定义虚拟库对应的 dataNode
        </schema>
        <dataNode name="dn1" dataHost="localhost1" database="testdb" />
        // 配置datanode 对应的 dataHost ， database字段为真实数据库（如后端mysql）的库名
        
        <dataHost name="localhost1" maxCon="1000" minCon="10" balance="4"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
				// 数据库后端的一些配置 必输数据库类型 最大最小连接，负载均衡类型。
				// 负载均衡类型：
				// 1. balance="0" 不开启读写分离，所有读写发送到 writeHost 上
				// 2. balance="1" 全部的readHost 与 stand by writeHost 参与读的 负载均衡
				// 3. balance="2" 所有数据库writeHost 与 readHost  参与读操作
				// 4. balance="3" 所有读请求随机分发到redHost 上， writeHost不参与
				
				// writeType
				// writeType=0 所有写操作发送给第一个Writehost  推荐使用0 默认项
				
				// swithchType=1  1 自动切换
				// 							 -1 不切换
				
				
                <heartbeat>select user()</heartbeat>
                // 心跳配置
                
                <!-- can have multi write hosts -->
                <writeHost host="hostM1" url="10.60.20.104:3306" user="root"
                                   password="123456">
                // 写主机配置
                <!-- can have multi read hosts -->
                <readHost host="hostS2" url="10.60.20.105:3306" user="root" password="xxx" />
                // 读主机配置
```







#### 3.启动服务

1)  在mycat/bin 目录下 执行 ./mycat console 控制台启动

2) 在mycat/bin 目录下 执行 ./mycat start     后台启动

**管理 端口：9066**

**服务 端口：8066**

### 搭建读写分离

#### 1.搭建mysql的读写分离（一主一从）

master

```
server-id=1
log-bin=mysql-bin
binlog_format
```

slave

```
server-id=2
relay-log=mysql-relay
```

有两种方式，1.在主库上指定主库二进制日志记录的库或忽略的库：

```
vim  /etc/my.cnf
    ...
    binlog-do-db=xxxx   二进制日志记录的数据库
    binlog-ignore-db=xxxx 二进制日志中忽略数据库
    以上任意指定其中一行参数就行，如果需要忽略多个库，则添加多行
    ...<br>重启mysql
```

 2.在从库上指定复制哪些库或者不负责哪些库

```
#编辑my.cnf，在mysqld字段添加如下内容：
  
replicate-do-db    设定需要复制的数据库
replicate-ignore-db 设定需要忽略的复制数据库
replicate-do-table  设定需要复制的表
replicate-ignore-table 设定需要忽略的复制表
replicate-wild-do-table 同replication-do-table功能一样，但是可以通配符
replicate-wild-ignore-table 同replication-ignore-table功能一样，但是可以加通配符
```

#### 2.搭建mysql的读写分离（双主双从）

1. 在配置mastar 的时候添加

log-slave-update                  // 作为从库写入binlog

auto-increment-increment=2 // binlog_pos 步长

auto-increment-offset=2       //开始的 offset  一个配置成1 一个配置成2 

2. 修改 schema.xml

```
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">

        <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="102" dataNode="dn1">
        </schema>
        <dataNode name="dn1" dataHost="localhost1" database="testdb" />
        <dataHost name="localhost1" maxCon="1000" minCon="10" balance="0"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <!-- can have multi write hosts -->
                <writeHost host="hostM1" url="10.60.20.104:3306" user="root"
                                   password="123456">
                        <!-- can have multi read hosts -->
                        <readHost host="hostS1" url="10.60.20.105:3306" user="root" password="xxx" />
                </writeHost>
                <writeHost host="hostM2" url="10.60.20.106:3306" user="root"
                                   password="123456">
                        <!-- can have multi read hosts -->
                        <readHost host="hostS2" url="10.60.20.107:3306" user="root" password="xxx" />
                </writeHost>
        </dataHost>
</mycat:schema>
```



### 垂直拆分--分库操作

**不同的服务器上的表不能进行关联操作**

1. 修改 schema.xml

```
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">

        <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="102" dataNode="dn1">
        		//添加一张新的表 拦截
        		<table name="customer" dataNode="dn2"> </table>
        </schema>
        <dataNode name="dn1" dataHost="host1" database="orders" />
        
        // 添加一个新的节点
        <dataNode name="dn2" dataHost="host2" database="orders" />
        <dataHost name="host1" maxCon="1000" minCon="10" balance="0"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <!-- can have multi write hosts -->
                <writeHost host="hostM1" url="10.60.20.104:3306" user="root"
                                   password="123456">
                        <!-- can have multi read hosts -->
                </writeHost>
        </dataHost>
        
        // 添加一个新的 datahost
        <dataHost name="host2" maxCon="1000" minCon="10" balance="0"
                          writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <!-- can have multi write hosts -->
                <writeHost host="hostM1" url="10.60.20.105:3306" user="root"
                                   password="123456">
                        <!-- can have multi read hosts -->
                </writeHost>
        </dataHost>
</mycat:schema>
```

2. 添加数据库 orders
3. 将数据导入



### 水平拆分--分表操作

根据 表的字段规则进行表的拆分。 1000万数据是mysql 的瓶颈。

原则：尽量将查询分配到不同的数据库

修改 schema.xml

```
 <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="102" dataNode="dn1">
        		<table name="customer" dataNode="dn2"> </table>
        		
        		//添加一张新的表 order 拦截, order 分配到两张表， 分表规则名字为 mod_rule
        		<table name="order" dataNode="dn1,dn2"  rule="mod_rule"> </table>
        </schema>
```

配置 rule.xml

```
// 添加规则
<tableRule name="mod_rule">
                <rule>
                        <columns>id</columns>
                        // 配置使用的算法 mod-long 取模
                        <algorithm>mod-log</algorithm>
                </rule>
        </tableRule>
        ...
        ...
        
        // 修改算法mod-long 使用的节点数量。
        <function name="mod-long" class="io.mycat.route.function.PartitionByMod">
                <!-- how many data nodes -->
                <property name="count">2</property>
        </function>
```

#### 插入操作

**使用mycat 分表进行插入操作   必须指明字段名称**

#### join操作（ER表）

要实现与order 表 与 order_detail 表的join 操作。order_detail也需要进行分片。

由于order 表通过id 字段进行的分表操作。

order_detail 表 的customer_id  与 order 表通过id 有关联关系。 这种关联关系成为E-R 关系。

- 修改 schema.xml

```
 <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="102" dataNode="dn1">
        		<table name="customer" dataNode="dn2"> </table>
        	
        	<table name="order" dataNode="dn1,dn2"  rule="mod_rule"> 
        	// 添加子表 order_detail 表主键 id，发生关联的字段 order_id，主表的key字段 id
        	<childTable name="order_detail" primaryKey="id" joinKey="order_id" parentKey="id" />
        		</table>
        </schema>
```

#### join操作（全局表）

字典表 所有表 都需要 所以需要同步到所有的表

- 修改 schema.xml

```
 <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="102" dataNode="dn1">
     <table name="customer" dataNode="dn2"> </table>
        	
     <table name="order" dataNode="dn1,dn2"  rule="mod_rule"> 
        	// 添加子表 order_detail 表主键 id，发生关联的字段 order_id，主表的key字段 id
        	<childTable name="order_detail" primaryKey="id" joinKey="order_id" parentKey="id" />
		/table>
		// type="global" 全局表的配置
		<table name="dict_order_type" dataNode="dn1,dn2" type="global"></tables>
</schema>
```



#### 常用算法

1. 取模
2. 分片枚举（hash-int） 例如 省份/区域 进行数据库的划分
3. 范围约定
4. 日期分片

### 全局序列

保证 数据库自增主键的全局唯一

#### 1. 本地方式

不推荐 不安全

####2. 数据库方式

1. 创建全局序列表
2. 创建全局序列函数
3. 修改sequence_db_conf.properties 指定边所在是datanode
4. server.xml  将`sequnceHandlerType` 修改为1

#### 3. 时间戳

不推荐 ID 太长

### Mycat 高可用  HAProxy + keepalive

### 安全配置

####  1. 库级别 只读

```
<user name="Mycat">
                <property name="password">123456</property>
                <property name="schemas">TESTDB</property>
                <property name="readOnly">true</property>
```



####  2. 表级别

```
<privileges check="true">
												// 默认所有权限
                        <schema name="TESTDB" dml="1111" >
                        				// 定义某一个表的权限
                                <table name="tb01" dml="0000"></table>
                                <table name="tb02" dml="1111"></table>
                        </schema>
                </privileges>
```

权限关系：

| DML权限 | 增加 | 更新 | 查询 | 删除 |
| ------- | ---- | ---- | ---- | ---- |
| 0000    | 禁止 | 禁止 | 禁止 | 禁止 |
| 0010    | 禁止 | 禁止 | 可以 | 禁止 |
| 1110    | 可以 | 禁止 | 禁止 | 禁止 |
| 1111    | 可以 | 可以 | 可以 | 可以 |



#### 3. SQL 拦截

1. 白名单

```
 <firewall> 
           <whitehost>
              <host host="127.0.0.1" user="mycat"/>
              <host host="127.0.0.2" user="mycat"/>
           </whitehost>
       <blacklist check="false">
       </blacklist>
        </firewall>
```

2.  黑名单

设置操作权限

```
 <firewall> 
           <whitehost>
              <host host="127.0.0.1" user="mycat"/>
              <host host="127.0.0.2" user="mycat"/>
           </whitehost>
       <blacklist check="true">
       		 <property name="deleteAllow">false</property>
       </blacklist>
        </firewall>
```
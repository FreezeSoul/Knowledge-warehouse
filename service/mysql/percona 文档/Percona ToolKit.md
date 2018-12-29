# Percona ToolKit

[TOC]



## 数据库连接配置 DSN Configuration

DSN 用于 配置 Percona ToolKit 的连接属性。

配置格式为：

```
DSN syntax is key=value[,key=value...]  Allowable DSN keys:

  KEY  COPY  MEANING
  ===  ====  =============================================
  A    yes   Default character set
  D    yes   Default database
  F    yes   Only read default options from the given file
  P    yes   Port number to use for connection
  S    yes   Socket file to use for connection
  h    yes   Connect to host
  p    yes   Password to use when connecting
  u    yes   User for login if not current user
```

例如

```
$ pt-config-diff h=192.168.0.167,u=pycf,p=1qaz@WSXabc,P=3320 h=192.168.0.167,u=pycf,p=1qaz@WSXabc,P=3319
```



 ## pt-heartbeat  数据库主从监控

- 配置数据库主库

```
pt-heartbeat -D <库名> --update  --create-table --replace <主库DSN配置> --daemonize
```

**说明: **

1. 使用的数据库 必须在主从同步的范围之内
2. 该命令会在 -D 的数据库中创建一个  `heartbeat` 表
3. 该命令会在后台执行

- 检查从库延迟

```
pt-heartbeat -D <库名> <从库DSN 配置> --check --master-server-id=<主库server_id>
pt-heartbeat -D <库名> <从库DSN 配置> --monitor --master-server-id=<主库server_id>
```

**说明：**

1. 使用参数 `--check` 检查一次，使用参数 `--monitor` 会持续的进行检查
2. --master-server-id 必须添加并填写正确的主库ID
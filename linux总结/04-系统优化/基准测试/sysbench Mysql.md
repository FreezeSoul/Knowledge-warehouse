什么是SysBench？如果您定期使用MySQL，那么您很可能已经听说过它。SysBench已经在MySQL生态系统中存在了很长时间。它最初由Peter Zaitsev编写，早在2004年。它的目的是提供一个工具来运行MySQL的综合基准测试及其运行的硬件。它旨在运行CPU，内存和I / O测试。它还有一个在MySQL数据库上执行OLTP工作负载的选项。OLTP代表在线交易处理，是电子商务，订单输入或金融交易系统等在线应用程序的典型工作量。

在这篇博文中，我们将重点介绍SQL基准测试功能，但请记住，硬件基准测试在识别数据库服务器上的问题时也非常有用。例如，I / O基准测试用于模拟InnoDB I / O工作负载，而CPU测试涉及高度并发，多线程环境的模拟以及互斥锁争用测试 - 这也类似于数据库类型的工作负载。

## SysBench的历史和架构

如上所述，SysBench最初由Peter Zaitsev于2004年创建。不久之后，Alexey Kopytov接管了它的开发。它达到0.4.12版本，开发停止了。经过长时间的休整，Alexey在2016年再次开始在SysBench上工作。很快发布了0.5版，OLTP基准测试被重写为使用基于LUA的脚本。然后，在2017年，SysBench 1.0发布了。与旧的0.4.12版本相比，这就像白天和黑夜。首先，最重要的是，现在我们可以使用LUA自定义基准测试，而不是硬编码脚本。例如，Percona创建了[类似TPCC的基准](https://github.com/Percona-Lab/sysbench-tpcc)，可以使用SysBench执行。让我们快速浏览一下当前的SysBench架构。

SysBench是一个C二进制文件，它使用LUA脚本来执行基准测试。这些脚本必须：

1. 处理来自命令行参数的输入
2. 定义基准测试应该使用的所有模式（准备，运行，清理）
3. 准备所有数据
4. 定义基准测试的执行方式（查询的外观等）

脚本可以利用与数据库的多个连接，如果您想创建复杂的基准测试，它们也可以处理结果，其中查询依赖于先前查询的结果集。使用SysBench 1.0，可以创建延迟直方图。LUA脚本也可以通过错误挂钩捕获和处理错误。在LUA脚本中支持并行化，可以并行执行多个查询，例如，可以更快地进行配置。最后但并非最不重要的是，现在支持多种输出格式。在SysBench生成只有人类可读的输出之前。现在可以将其生成为CSV或JSON，从而可以更轻松地使用例如gnuplot进行后处理和生成图形，或将数据提供给Prometheus，Graphite或类似的数据存储。

## 为什么选择SysBench？

SysBench变得流行的主要原因是它易于使用。没有事先知识的人可以在几分钟内开始使用它。默认情况下，它还提供涵盖大多数情况的基准测试 - OLTP工作负载，只读或读写，主键查找和主键更新。所有这些都导致了MySQL的大部分问题，直到MySQL 8.0。这也是为什么SysBench在互联网上发布的不同基准测试和比较中如此受欢迎的原因。这些帖子有助于推广这一工具，并使其成为MySQL的首选合成基准。

关于SysBench的另一个好处是，自0.5版本和LUA的合并，任何人都可以准备任何类型的基准。我们已经提到了类似TPCC的基准测试，但任何人都可以制作类似于她的生产工作量的东西。我们并不是说它很简单，它很可能是一个耗时的过程，但如果您需要准备自定义基准测试，那么拥有此功能是有益的。

作为综合基准测试，SysBench不是一种可用于调整MySQL服务器配置的工具（除非您使用自定义工作负载准备LUA脚本，或者您的工作负载与SysBench附带的基准工作负载非常相似）。它的优点在于比较不同硬件的性能。您可以轻松地比较云提供商提供的不同类型节点的性能，以及它们提供的最大QPS（每秒查询数）。知道该指标并知道您为给定节点支付的费用，您就可以计算更重要的指标 - QP $（每美元查询）。这将允许您确定在构建经济高效的环境时要使用的节点类型。当然，SysBench也可用于初始调整和评估给定设计的可行性。假设我们在全球范围内建立了一个Galera集群 - 北美，欧盟，亚洲。这样的设置可以处理每秒多少个插入？什么是提交延迟？做一个概念验证甚至网络延迟是否足够高，甚至一个简单的工作负载不能像你期望的那样工作也是有意义的。

压力测试怎么样？并非所有人都迁移到云端，仍然有公司倾向于建立自己的基础设施。获得的每台新服务器都应经历一段预热期，在此期间您将强调它以查明潜在的硬件缺陷。在这种情况下，SysBench也可以提供帮助。通过执行使服务器过载的OLTP工作负载，或者也可以使用CPU，磁盘和内存的专用基准测试。

如您所见，在许多情况下，即使是简单的综合基准测试也非常有用。在下一段中，我们将看看我们可以用SysBench做些什么。

## SysBench可以为您做什么？

### 您可以运行哪些测试？

正如开头所提到的，我们将专注于OLTP基准测试，并且作为提醒我们将重复SysBench也可以用于执行I / O，CPU和内存测试。我们来看看SysBench 1.0附带的基准测试（我们从这个列表中删除了一些辅助LUA文件和非数据库LUA脚本）。

```bash
`-rwxr-xr-x 1 root root 1.5K May 30 07:46 bulk_insert.lua``-rwxr-xr-x 1 root root 1.3K May 30 07:46 oltp_delete.lua``-rwxr-xr-x 1 root root 2.4K May 30 07:46 oltp_insert.lua``-rwxr-xr-x 1 root root 1.3K May 30 07:46 oltp_point_select.lua``-rwxr-xr-x 1 root root 1.7K May 30 07:46 oltp_read_only.lua``-rwxr-xr-x 1 root root 1.8K May 30 07:46 oltp_read_write.lua``-rwxr-xr-x 1 root root 1.1K May 30 07:46 oltp_update_index.lua``-rwxr-xr-x 1 root root 1.2K May 30 07:46 oltp_update_non_index.lua``-rwxr-xr-x 1 root root 1.5K May 30 07:46 oltp_write_only.lua``-rwxr-xr-x 1 root root 1.9K May 30 07:46 select_random_points.lua``-rwxr-xr-x 1 root root 2.1K May 30 07:46 select_random_ranges.lua`
```

让我们一个接一个地看看。

首先，bulk_insert.lua。此测试可用于基准测试MySQL执行多行插入的能力。在检查复制性能或Galera集群时，这非常有用。在第一种情况下，它可以帮助您回答一个问题：“在复制延迟启动之前我可以多快插入？”。在后一种情况下，它会告诉您在给定当前网络延迟的情况下，如何将数据插入Galera集群的速度。

所有oltp_ *脚本共享一个公共表结构。前两个（oltp_delete.lua和oltp_insert.lua）执行单个DELETE和INSERT语句。同样，这可能是对复制或Galera集群的测试 - 将其推到极限并查看它可以处理的插入或清除量。我们还有其他针对特定功能的基准测试 - oltp_point_select，oltp_update_index和oltp_update_non_index。这些将执行查询的子集 - 基于主键的选择，基于索引的更新和基于非索引的更新。如果你想测试其中的一些功能，测试就在那里。我们还有更复杂的基准测试，它们基于OLTP工作负载：oltp_read_only，oltp_read_write和oltp_write_only。您可以运行只读工作负载，该工作负载将包含不同类型的SELECT查询，你只能运行写入（DELETE，INSERT和UPDATE的混合），或者你可以运行这两者的混合。最后，使用select_random_points和select_random_ranges，您可以使用IN（）列表中的随机点或使用BETWEEN的随机范围运行一些随机SELECT。

### 如何配置基准？

同样重要的是，基准测试是可配置的 - 您可以使用相同的基准测试运行不同的工作负载模式。我们来看看要执行的两个最常见的基准测试。我们将深入研究OLTP read_only和OLTP read_write基准测试。首先，SysBench有一些常规配置选项。我们将在这里讨论最重要的一些，您可以通过运行来检查所有这些：

```bash
`sysbench --help`
```

我们来看看它们。

```bash
`--threads=N                     number of threads to use [1]`
```

您可以定义您希望SysBench生成哪种并发。MySQL，作为每个软件，都有一些可扩展性限制，其性能将达到某种程度的并发性。此设置有助于模拟给定工作负载的不同并发，并检查它是否已通过最佳位置。

```bash
`--events=N                      limit ``for` `total number of events [0]``--``time``=N                        limit ``for` `total execution ``time` `in` `seconds [10]`
```

这两个设置决定了SysBench应该保持运行的时间。它可以执行一些查询，也可以在预定义的时间内继续运行。

```bash
`--warmup-``time``=N                 execute events ``for` `this many seconds with statistics disabled before the actual benchmark run with statistics enabled [0]`
```

这是不言自明的。SysBench从测试中生成统计结果，如果MySQL处于冷态，这些结果可能会受到影响。预热有助于通过执行预定义时间的基准来识别“常规”吞吐量，允许预热缓存，缓冲池等。

```bash
`--rate=N                        average transactions rate. 0 ``for` `unlimited rate [0]`
```

默认情况下，SysBench将尝试尽快执行查询。要模拟较慢的流量，可以使用此选项。您可以在此定义每秒应执行的事务数。

```bash
`--report-interval=N             periodically report intermediate statistics with a specified interval ``in` `seconds. 0 disables intermediate reports [0]`
```

默认情况下，SysBench在完成运行后生成报告，并且在基准运行时未报告任何进度。使用此选项可以在基准测试仍然运行时使SysBench更加冗长。

```bash
`--rand-``type``=STRING   random numbers distribution {uniform, gaussian, special, pareto, zipfian} to use by default [special]`
```

SysBench使您能够生成不同类型的数据分发。他们所有人都有自己的目的。默认选项“特殊”定义了数据中的几个（可配置的）热点，这在Web应用程序中很常见。如果您的数据以不同的方式运行，您还可以使用其他分发。通过在此处进行不同的选择，您还可以更改数据库的压力方式。例如，均匀分布，其中所有行具有相同的被访问的可能性，是更多的内存密集型操作。它将使用更多缓冲池来存储所有数据，如果您的数据集不适合内存，则会占用更多磁盘。另一方面，具有几个热点的特殊分发将减少磁盘上的压力，因为热行更可能保留在缓冲池中，并且访问存储在磁盘上的行的可能性要小得多。对于某些数据分发类型，SysBench为您提供了更多调整。您可以在'sysbench --help'输出中找到此信息。

```bash
`--db-``ps``-mode=STRING prepared statements usage mode {auto, disable} [auto]`
```

使用此设置，您可以决定SysBench是否应使用预准备语句（只要它们在给定数据存储中可用 - 对于MySQL，它意味着PS将默认启用）或不使用。在使用ProxySQL或MaxScale等代理时，这可能会有所不同 - 它们应该以特殊方式处理预准备语句，并且所有这些语句都应该路由到一个主机，从而无法测试代理的可伸缩性。

除了常规配置选项之外，每个测试都可以有自己的配置。您可以通过运行检查可能的内容：

```bash
`root@vagrant:~``# sysbench ./sysbench/src/lua/oltp_read_write.lua  help``sysbench 1.1.0-2e6b7d5 (using bundled LuaJIT 2.1.0-beta3)` `oltp_read_only.lua options:``  ``--distinct_ranges=N           Number of SELECT DISTINCT queries per transaction [1]``  ``--sum_ranges=N                Number of SELECT SUM() queries per transaction [1]``  ``--skip_trx[=on|off]           Don't start explicit transactions and execute all queries ``in` `the AUTOCOMMIT mode [off]``  ``--secondary[=on|off]          Use a secondary index ``in` `place of the PRIMARY KEY [off]``  ``--create_secondary[=on|off]   Create a secondary index ``in` `addition to the PRIMARY KEY [on]``  ``--index_updates=N             Number of UPDATE index queries per transaction [1]``  ``--range_size=N                Range size ``for` `range SELECT queries [100]``  ``--auto_inc[=on|off]           Use AUTO_INCREMENT column as Primary Key (``for` `MySQL), or its alternatives ``in` `other DBMS. When disabled, use client-generated IDs [on]``  ``--delete_inserts=N            Number of DELETE``/INSERT` `combinations per transaction [1]``  ``--tables=N                    Number of tables [1]``  ``--mysql_storage_engine=STRING Storage engine, ``if` `MySQL is used [innodb]``  ``--non_index_updates=N         Number of UPDATE non-index queries per transaction [1]``  ``--table_size=N                Number of rows per table [10000]``  ``--pgsql_variant=STRING        Use this PostgreSQL variant when running with the PostgreSQL driver. The only currently supported variant is ``'redshift'``. When enabled, create_secondary is automatically disabled, and delete_inserts is ``set` `to 0``  ``--simple_ranges=N             Number of simple range SELECT queries per transaction [1]``  ``--order_ranges=N              Number of SELECT ORDER BY queries per transaction [1]``  ``--range_selects[=on|off]      Enable``/disable` `all range SELECT queries [on]``  ``--point_selects=N             Number of point SELECT queries per transaction [10]`
```

同样，我们将从这里讨论最重要的选项。首先，您可以控制交易的完整程度。一般来说，它由不同类型的查询组成 - INSERT，DELETE，不同类型的SELECT（点查找，范围，聚合）和UPDATE（索引，非索引）。使用如下变量：

```bash
`--distinct_ranges=N           Number of SELECT DISTINCT queries per transaction [1]``--sum_ranges=N                Number of SELECT SUM() queries per transaction [1]``--index_updates=N             Number of UPDATE index queries per transaction [1]``--delete_inserts=N            Number of DELETE``/INSERT` `combinations per transaction [1]``--non_index_updates=N         Number of UPDATE non-index queries per transaction [1]``--simple_ranges=N             Number of simple range SELECT queries per transaction [1]``--order_ranges=N              Number of SELECT ORDER BY queries per transaction [1]``--point_selects=N             Number of point SELECT queries per transaction [10]``--range_selects[=on|off]      Enable``/disable` `all range SELECT queries [on]`
```

您可以定义事务的外观。通过查看默认值可以看出，大多数查询都是SELECT - 主要是点选择，但也有不同类型的范围SELECT（您可以通过将range_selects设置为off来禁用所有这些）。您可以通过增加更新次数或INSERT / DELETE查询来调整工作负载以适应更多写入繁重的工作负载。还可以调整与二级索引相关的设置，自动增量以及数据集大小（表的数量以及每个应该保持多少行）。这使您可以非常好地自定义工作负载。

```bash
`--skip_trx[=on|off]           Don't start explicit transactions and execute all queries ``in` `the AUTOCOMMIT mode [off]`
```

这是另一个设置，在使用代理时非常重要。默认情况下，SysBench将尝试在显式事务中执行查询。这样，数据集将保持一致且不受影响：例如，SysBench将在同一行上执行INSERT和DELETE，确保数据集不会增长（影响您重现结果的能力）。但是，代理将以不同方式处理显式事务 - 在事务中执行的所有查询都应在同一主机上执行，从而无法扩展工作负载。请记住，禁用事务会导致数据集偏离初始点。它还可能触发一些问题，如重复键错误等。为了能够禁用事务，您可能还需要查看：

```bash
`--mysql-ignore-errors=[LIST,...] list of errors to ignore, or ``"all"` `[1213,1020,1205]`
```

此设置允许您指定来自MySQL的错误代码，SysBench应忽略该错误代码（而不是终止连接）。例如，要忽略错误，例如：错误1062（密钥'PRIMARY'的重复条目'6'），您应该传递此错误代码： - mysql-ignore-errors = 1062

同样重要的是，每个基准测试都应该提供一种方法来为测试配置数据集，运行它们，然后在测试完成后进行清理。这是使用'prepare'，'run'和'cleanup'命令完成的。我们将在下一节中展示如何完成此操作。

## 例子

在本节中，我们将介绍SysBench可用于的一些示例。如前所述，我们将专注于两个最受欢迎的基准测试 - OLTP只读和OLTP读/写。有时使用其他基准测试可能有意义，但至少我们将能够向您展示如何定制这两个基准测试。

### 主键查找

首先，我们必须决定运行哪个基准，只读或读写。从技术上讲，它没有任何区别，因为我们可以从R / W基准中删除写入。让我们专注于只读的一个。

作为第一步，我们必须准备一个数据集。我们需要决定它应该有多大。对于此特定基准测试，使用默认设置（因此，创建二级索引），100万行将产生~240 MB的数据。十个表，1000 000行，每行等于2.4GB：

```bash
`root@vagrant:~``# du -sh /var/lib/mysql/sbtest/``2.4G    ``/var/lib/mysql/sbtest/``root@vagrant:~``# ls -alh /var/lib/mysql/sbtest/``total 2.4G``drwxr-x--- 2 mysql mysql 4.0K Jun  1 12:12 .``drwxr-xr-x 6 mysql mysql 4.0K Jun  1 12:10 ..``-rw-r----- 1 mysql mysql   65 Jun  1 12:08 db.opt``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:12 sbtest10.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:12 sbtest10.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:10 sbtest1.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:10 sbtest1.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:10 sbtest2.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:10 sbtest2.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:10 sbtest3.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:10 sbtest3.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:10 sbtest4.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:10 sbtest4.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:11 sbtest5.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:11 sbtest5.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:11 sbtest6.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:11 sbtest6.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:11 sbtest7.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:11 sbtest7.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:11 sbtest8.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:11 sbtest8.ibd``-rw-r----- 1 mysql mysql 8.5K Jun  1 12:12 sbtest9.frm``-rw-r----- 1 mysql mysql 240M Jun  1 12:12 sbtest9.ibd`
```

这应该可以让您了解您想要多少个表以及它们应该有多大。假设我们想测试内存工作负载，因此我们想要创建适合InnoDB缓冲池的表。另一方面，我们还希望确保有足够的表不会成为瓶颈（或者表的数量与您在生产设置中的预期相匹配）。让我们准备我们的数据集。请记住，默认情况下，SysBench会在准备数据集之前查找必须存在的“sbtest”架构。您可能必须手动创建它。

```bash
`root@vagrant:~``# sysbench /root/sysbench/src/lua/oltp_read_only.lua --threads=4 --mysql-host=10.0.0.126 --mysql-user=sbtest --mysql-password=pass --mysql-port=3306 --tables=10 --table-size=1000000 prepare``sysbench 1.1.0-2e6b7d5 (using bundled LuaJIT 2.1.0-beta3)` `Initializing worker threads...` `Creating table ``'sbtest2'``...``Creating table ``'sbtest3'``...``Creating table ``'sbtest4'``...``Creating table ``'sbtest1'``...``Inserting 1000000 records into ``'sbtest2'``Inserting 1000000 records into ``'sbtest4'``Inserting 1000000 records into ``'sbtest3'``Inserting 1000000 records into ``'sbtest1'``Creating a secondary index on ``'sbtest2'``...``Creating a secondary index on ``'sbtest3'``...``Creating a secondary index on ``'sbtest1'``...``Creating a secondary index on ``'sbtest4'``...``Creating table ``'sbtest6'``...``Inserting 1000000 records into ``'sbtest6'``Creating table ``'sbtest7'``...``Inserting 1000000 records into ``'sbtest7'``Creating table ``'sbtest5'``...``Inserting 1000000 records into ``'sbtest5'``Creating table ``'sbtest8'``...``Inserting 1000000 records into ``'sbtest8'``Creating a secondary index on ``'sbtest6'``...``Creating a secondary index on ``'sbtest7'``...``Creating a secondary index on ``'sbtest5'``...``Creating a secondary index on ``'sbtest8'``...``Creating table ``'sbtest10'``...``Inserting 1000000 records into ``'sbtest10'``Creating table ``'sbtest9'``...``Inserting 1000000 records into ``'sbtest9'``Creating a secondary index on ``'sbtest10'``...``Creating a secondary index on ``'sbtest9'``...`
```

获得数据后，让我们准备一个命令来运行测试。我们想测试主键查找，因此我们将禁用所有其他类型的SELECT。我们还将禁用预准备语句，因为我们要测试常规查询。我们将测试低并发性，比方说16个线程。我们的命令可能如下所示：

```bash
`sysbench ``/root/sysbench/src/lua/oltp_read_only``.lua --threads=16 --events=0 --``time``=300 --mysql-host=10.0.0.126 --mysql-user=sbtest --mysql-password=pass --mysql-port=3306 --tables=10 --table-size=1000000 --range_selects=off --db-``ps``-mode=disable --report-interval=1 run`
```

我们在这做了什么？我们将线程数设置为16.我们决定我们希望我们的基准测试运行300秒，没有执行查询的限制。我们定义了与数据库的连接，表的数量及其大小。我们还禁用了所有范围的SELECT，我们也禁用了预处理语句。最后，我们将报告间隔设置为一秒。这是示例输出的样子：

```bash
`[ 297s ] thds: 16 tps: 97.21 qps: 1127.43 (r``/w/o``: 935.01``/0``.00``/192``.41) lat (ms,95%): 253.35 err``/s``: 0.00 reconn``/s``: 0.00``[ 298s ] thds: 16 tps: 195.32 qps: 2378.77 (r``/w/o``: 1985.13``/0``.00``/393``.64) lat (ms,95%): 189.93 err``/s``: 0.00 reconn``/s``: 0.00``[ 299s ] thds: 16 tps: 178.02 qps: 2115.22 (r``/w/o``: 1762.18``/0``.00``/353``.04) lat (ms,95%): 155.80 err``/s``: 0.00 reconn``/s``: 0.00``[ 300s ] thds: 16 tps: 217.82 qps: 2640.92 (r``/w/o``: 2202.27``/0``.00``/438``.65) lat (ms,95%): 125.52 err``/s``: 0.00 reconn``/s``: 0.00`
```

每秒我们都会看到工作负载统计信息的快照。这对跟踪和绘图非常有用 - 最终报告仅给出平均值。中间结果将使得可以逐秒跟踪性能。最终报告可能如下所示：

```bash
`SQL statistics:``    ``queries performed:``        ``read``:                            614660``        ``write:                           0``        ``other:                           122932``        ``total:                           737592``    ``transactions:                        61466  (204.84 per sec.)``    ``queries:                             737592 (2458.08 per sec.)``    ``ignored errors:                      0      (0.00 per sec.)``    ``reconnects:                          0      (0.00 per sec.)` `Throughput:``    ``events``/s` `(eps):                      204.8403``    ``time` `elapsed:                        300.0679s``    ``total number of events:              61466` `Latency (ms):``         ``min:                                   24.91``         ``avg:                                   78.10``         ``max:                                  331.91``         ``95th percentile:                      137.35``         ``sum``:                              4800234.60` `Threads fairness:``    ``events (avg``/stddev``):           3841.6250``/20``.87``    ``execution ``time` `(avg``/stddev``):   300.0147``/0``.02`
```

您将在此处找到有关已执行查询和其他（BEGIN / COMMIT）语句的信息。您将了解执行了多少事务，发生了多少错误，吞吐量和总耗用时间。您还可以检查延迟指标和跨线程的查询分布。

如果我们对延迟分布感兴趣，我们也可以将'--histogram'参数传递给SysBench。这会产生如下额外输出：

```bash
`Latency histogram (values are ``in` `milliseconds)``       ``value  ------------- distribution ------------- count``      ``29.194 |******                                   1``      ``30.815 |******                                   1``      ``31.945 |***********                              2``      ``33.718 |******                                   1``      ``34.954 |***********                              2``      ``35.589 |******                                   1``      ``37.565 |***********************                  4``      ``38.247 |******                                   1``      ``38.942 |******                                   1``      ``39.650 |***********                              2``      ``40.370 |***********                              2``      ``41.104 |*****************                        3``      ``41.851 |*****************************            5``      ``42.611 |*****************                        3``      ``43.385 |*****************                        3``      ``44.173 |***********                              2``      ``44.976 |**************************************** 7``      ``45.793 |***********************                  4``      ``46.625 |***********                              2``      ``47.472 |*****************************            5``      ``48.335 |**************************************** 7``      ``49.213 |***********                              2``      ``50.107 |**********************************       6``      ``51.018 |***********************                  4``      ``51.945 |**************************************** 7``      ``52.889 |*****************                        3``      ``53.850 |*****************                        3``      ``54.828 |***********************                  4``      ``55.824 |***********                              2``      ``57.871 |***********                              2``      ``58.923 |***********                              2``      ``59.993 |******                                   1``      ``61.083 |******                                   1``      ``63.323 |***********                              2``      ``66.838 |******                                   1``      ``71.830 |******                                   1`
```

一旦我们对结果很满意，我们就可以清理数据：

```bash
`sysbench ``/root/sysbench/src/lua/oltp_read_only``.lua --threads=16 --events=0 --``time``=300 --mysql-host=10.0.0.126 --mysql-user=sbtest --mysql-password=pass --mysql-port=3306 --tables=10 --table-size=1000000 --range_selects=off --db-``ps``-mode=disable --report-interval=1 cleanup`
```

### 写入繁重的流量

让我们想象一下，我们想要执行一个写入繁重（但不是只写）的工作负载，例如，测试I / O子系统的性能。首先，我们必须决定数据集应该有多大。我们假设~48GB的数据（20个表，每个10 000 000行）。我们需要做好准备。这次我们将使用读写基准。

```bash
`root@vagrant:~``# sysbench /root/sysbench/src/lua/oltp_read_write.lua --threads=4 --mysql-host=10.0.0.126 --mysql-user=sbtest --mysql-password=pass --mysql-port=3306 --tables=20 --table-size=10000000 prepare`
```

完成此操作后，我们可以调整默认值以强制更多写入查询组合：

```bash
`root@vagrant:~``# sysbench /root/sysbench/src/lua/oltp_read_write.lua --threads=16 --events=0 --time=300 --mysql-host=10.0.0.126 --mysql-user=sbtest --mysql-password=pass --mysql-port=3306 --tables=20 --delete_inserts=10 --index_updates=10 --non_index_updates=10 --table-size=10000000 --db-ps-mode=disable --report-interval=1 run`
```

正如您从中间结果中看到的那样，交易现在处于写作重点：

```bash
`[ 5s ] thds: 16 tps: 16.99 qps: 946.31 (r``/w/o``: 231.83``/680``.50``/33``.98) lat (ms,95%): 1258.08 err``/s``: 0.00 reconn``/s``: 0.00``[ 6s ] thds: 16 tps: 17.01 qps: 955.81 (r``/w/o``: 223.19``/698``.59``/34``.03) lat (ms,95%): 1032.01 err``/s``: 0.00 reconn``/s``: 0.00``[ 7s ] thds: 16 tps: 12.00 qps: 698.91 (r``/w/o``: 191.97``/482``.93``/24``.00) lat (ms,95%): 1235.62 err``/s``: 0.00 reconn``/s``: 0.00``[ 8s ] thds: 16 tps: 14.01 qps: 683.43 (r``/w/o``: 195.12``/460``.29``/28``.02) lat (ms,95%): 1533.66 err``/s``: 0.00 reconn``/s``: 0.00`
```

相关资源

[ ClusterControl for MySQL](https://severalnines.com/product/clustercontrol/for_mysql)

[ MariaDB的ClusterControl](https://severalnines.com/product/clustercontrol/mariadb-database-management-system)

[ 如何在AWS和Google Cloud上高度可用的MySQL或MariaDB数据库](https://severalnines.com/blog/how-make-mysql-mariadb-database-highly-available-aws-google-cloud)

## 了解结果

如上所示，SysBench是一个很好的工具，可以帮助查明MySQL或MariaDB的一些性能问题。它还可用于初始调整数据库配置。当然，您必须记住，为了充分利用您的基准测试，您必须了解为什么结果看起来像他们一样。这需要使用监视工具（例如[ClusterControl）](https://severalnines.com/product/clustercontrol)深入了解MySQL内部指标。记住这一点非常重要 - 如果您不理解为什么表现如此，您可能会从基准测试中得出错误的结论。总是存在瓶颈，SysBench可以帮助提高性能问题，然后您必须确定这些问题。
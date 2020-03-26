# 使用sysbench 进行基准测试 (CPU, File IO, MySQL) 

[git 项目地址](https://github.com/akopytov/sysbench)

[使用文档 版本较旧](https://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench)

[TOC]

sysbench 是一个基准测试套件，它允许您快速获得系统性能的指标，这对于在密集负载下运行数据库非常重要。本文解释如何使用sysbench对您的CPU、文件IO和MySQL性能进行基准测试。

## 1 安装 sysbench

不同的系统安装可以参考 git 项目 文档

CentOs 安装步骤如下

```
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum -y install sysbench
```



## 2 CPU 基准测试

可以使用以下命令进行CPU 基准测试：

```
sysbench --test=cpu --cpu-max-prime=20000 run
root@server1:~# sysbench --test=cpu --cpu-max-prime=20000 run
sysbench 0.4.12:  multi-threaded system evaluation benchmark
 
Running the test with following options:
Number of threads: 1
 
Doing CPU performance benchmark
 
Threads started!
Done.
 
Maximum prime number checked in CPU test: 20000
 
 
Test execution summary:
    total time:                          23.8724s
    total number of events:              10000
    total time taken by event execution: 23.8716
    per-request statistics:
         min:                                  2.31ms
         avg:                                  2.39ms
         max:                                  6.39ms
         approx.  95 percentile:               2.44ms
 
Threads fairness:
    events (avg/stddev):           10000.0000/0.00
    execution time (avg/stddev):   23.8716/0.00
 
root@server1:~#
```

You see a lot of numbers, the most important of it is the total time:

​    total time:                          23.8724s

Of course, you must compare benchmarks across multiple systems to know what these numbers are worth.

## 3 File IO Benchmark

To measure file IO performance, we first need to create a test file that is much bigger than your RAM (because otherwise, the system will use RAM for caching which tampers with the benchmark results) - 150GB is a good value:

```
sysbench --test=fileio --file-total-size=150G prepare
```

Afterwards, we can run the benchmark:

```
sysbench --test=fileio --file-total-size=150G --file-test-mode=rndrw --init-rng=on --max-time=300 --max-requests=0 run
root@server1:~# sysbench --test=fileio --file-total-size=150G --file-test-mode=rndrw --init-rng=on --max-time=300 --max-requests=0 run
sysbench: /usr/lib/libmysqlclient.so.18: no version information available (required by sysbench)
sysbench 0.4.12:  multi-threaded system evaluation benchmark
 
Running the test with following options:
Number of threads: 1
Initializing random number generator from timer.
 
 
Extra file open flags: 0
128 files, 1.1719Gb each
150Gb total file size
Block size 16Kb
Number of random requests for random IO: 0
Read/Write ratio for combined random IO test: 1.50
Periodic FSYNC enabled, calling fsync() each 100 requests.
Calling fsync() at the end of test, Enabled.
Using synchronous I/O mode
Doing random r/w test
Threads started!
Time limit exceeded, exiting...
Done.
 
Operations performed:  600 Read, 400 Write, 1186 Other = 2186 Total
Read 9.375Mb  Written 6.25Mb  Total transferred 15.625Mb  (53.316Kb/sec)
    3.33 Requests/sec executed
 
Test execution summary:
    total time:                          300.0975s
    total number of events:              1000
    total time taken by event execution: 158.7611
    per-request statistics:
         min:                                  0.01ms
         avg:                                158.76ms
         max:                               2596.96ms
         approx.  95 percentile:             482.29ms
 
Threads fairness:
    events (avg/stddev):           1000.0000/0.00
    execution time (avg/stddev):   158.7611/0.00
 
root@server1:~#
```

The important number is the Kb/sec value:

Read 9.375Mb  Written 6.25Mb  Total transferred 15.625Mb  (53.316Kb/sec)

After the benchmark, you can delete the 150GB test file from the system:

```
sysbench --test=fileio --file-total-size=150G cleanup
```

## 4 MySQL Benchmark

To measure MySQL performance, we first create a test table in the database test with 1,000,000 rows of data:

```
sysbench --test=oltp --oltp-table-size=1000000 --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=yourrootsqlpassword prepare
root@server1:~# sysbench --test=oltp --oltp-table-size=1000000 --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=yourrootsqlpassword prepare
sysbench 0.4.12: multi-threaded system evaluation benchmark
No DB drivers specified, using mysql
Creating table 'sbtest'...
Creating 1000000 records in table 'sbtest'...
root@server1:~#
```

Replace the word **\*yourrootsqlpassword*** with your MySQL root password in the above command. Do the same in the next commands.

Afterwards, you can run the MySQL benchmark as follows:

```
sysbench --test=oltp --oltp-table-size=1000000 --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=yourrootsqlpassword --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=8 run
root@server1:~# sysbench --test=oltp --oltp-table-size=1000000 --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=yourrootsqlpassword --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=8 run
sysbench 0.4.12:  multi-threaded system evaluation benchmark
 
No DB drivers specified, using mysql
Running the test with following options:
Number of threads: 8
 
Doing OLTP test.
Running mixed OLTP test
Doing read-only test
Using Special distribution (12 iterations,  1 pct of values are returned in 75 pct cases)
Using "BEGIN" for starting transactions
Using auto_inc on the id column
Threads started!
Time limit exceeded, exiting...
(last message repeated 7 times)
Done.
 
OLTP test statistics:
    queries performed:
        read:                            2253860
        write:                           0
        other:                           321980
        total:                           2575840
    transactions:                        160990 (2683.06 per sec.)
    deadlocks:                           0      (0.00 per sec.)
    read/write requests:                 2253860 (37562.81 per sec.)
    other operations:                    321980 (5366.12 per sec.)
 
Test execution summary:
    total time:                          60.0024s
    total number of events:              160990
    total time taken by event execution: 479.3419
    per-request statistics:
         min:                                  0.81ms
         avg:                                  2.98ms
         max:                               3283.40ms
         approx.  95 percentile:               4.62ms
 
Threads fairness:
    events (avg/stddev):           20123.7500/63.52
    execution time (avg/stddev):   59.9177/0.00
 
root@server1:~#
```

The important number is the transactions per second value:

​    transactions:                        160990 (2683.06 per sec.)



To clean up the system afterwards (i.e., remove the test table), run:

```
sysbench --test=oltp --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=yourrootsqlpassword cleanup
```

## 5 Links

- sysbench: <http://sysbench.sourceforge.net/>
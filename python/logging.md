# logging模块

## 1 日志级别

日志一共分成5个等级，从低到高分别是：`DEBUG` `INFO` `WARNING` `ERROR` `CRITICAL`。

**DEBUG**：详细的信息,通常只出现在诊断问题上
**INFO**：确认一切按预期运行
**WARNING**：一个迹象表明,一些意想不到的事情发生了,或表明一些问题在不久的将来(例如。磁盘空间低”)。这个软件还能按预期工作。
**ERROR**：更严重的问题,软件没能执行一些功能
**CRITICAL**：一个严重的错误,这表明程序本身可能无法继续运行

这5个等级，也分别对应5种打日志的方法： debug 、info 、warning 、error 、critical。默认的是WARNING，当在WARNING或之上时才被跟踪。



## 2 日志输出 

有两种方式记录跟踪，一种输出控制台，另一种是记录到文件中，如日志文件。



### 2.1 将日志输出到控制台

比如，编写一个叫做log.py的文件，如下：



```python
# coding=utf-8
import logging

logging.basicConfig(level=logging.WARNING,format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')

# use logging

logging.info('this is a loggging info message')
logging.debug('this is a loggging debug message')
logging.warning('this is loggging a warning message')
logging.error('this is an loggging error message')
logging.critical('this is a loggging critical message')
```

执行上面的代码将在Console中输出下面信息：


```
C:\Python27\python.exe C:/Users/liu.chunming/PycharmProjects/Myproject/log.py
2015-05-21 17:25:22,572 - log.py[line:10] - WARNING: this is loggging a warning message
2015-05-21 17:25:22,572 - log.py[line:11] - ERROR: this is an loggging error message
2015-05-21 17:25:22,572 - log.py[line:12] - CRITICAL: this is a loggging critical message
```
【解析】

通过logging.basicConfig函数对日志的输出格式及方式做相关配置，上面代码设置日志的输出等级是WARNING级别，意思是WARNING级别以上的日志才会输出。另外还制定了日志输出的格式。



### 2.2  将日志输出到文件

我们还可以将日志输出到文件，只需要在logging.basicConfig函数中设置好输出文件的文件名和写文件的模式。

```python
# coding=utf-8
import logging

logging.basicConfig(level=logging.WARNING,
                    filename='./log/log.txt',
                    filemode='w',
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')

# use logging

logging.info('this is a loggging info message')
logging.debug('this is a loggging debug message')
logging.warning('this is loggging a warning message')
logging.error('this is an loggging error message')
logging.critical('this is a loggging critical message')
```

运行之后，打开该文件./log/log.txt，效果如下：


```
2015-05-21 17:30:20,282 - log.py[line:12] - WARNING: this is loggging a warning message
2015-05-21 17:30:20,282 - log.py[line:13] - ERROR: this is an loggging error message
2015-05-21 17:30:20,282 - log.py[line:14] - CRITICAL: this is a loggging critical message
```


###  2.3 既要把日志输出到控制台， 还要写入日志文件

这就需要一个叫作Logger 的对象来帮忙，下面将对他进行详细介绍，现在这里先学习怎么实现把日志既要输出到控制台又要输出到文件的功能。



``` python
# coding=utf-8
import logging

# 第一步，创建一个logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)    # Log等级总开关
# 第二步，创建一个handler，用于写入日志文件
logfile = './log/logger.txt'
fh = logging.FileHandler(logfile, mode='w')
fh.setLevel(logging.DEBUG)   # 输出到file的log等级的开关

# 第三步，再创建一个handler，用于输出到控制台
ch = logging.StreamHandler()
ch.setLevel(logging.WARNING)   # 输出到console的log等级的开关
# 第四步，定义handler的输出格式
formatter = logging.Formatter("%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s")
fh.setFormatter(formatter)
ch.setFormatter(formatter)
# 第五步，将logger添加到handler里面
logger.addHandler(fh)
logger.addHandler(ch)
# 日志
logger.debug('this is a logger debug message')
logger.info('this is a logger info message')
logger.warning('this is a logger warning message')
logger.error('this is a logger error message')
logger.critical('this is a logger critical message')
```

执行这段代码之后，在console中，可以看到：


```
C:\Python27\python.exe C:/Users/liu.chunming/PycharmProjects/Myproject/log.py
2015-05-21 17:47:50,292 - log.py[line:30] - WARNING: this is a logger warning message
2015-05-21 17:47:50,292 - log.py[line:31] - ERROR: this is a logger error message
2015-05-21 17:47:50,293 - log.py[line:32] - CRITICAL: this is a logger critical message
在logger.txt中，可以看到：

2015-05-21 17:47:50,292 - log.py[line:29] - INFO: this is a logger info message
2015-05-21 17:47:50,292 - log.py[line:30] - WARNING: this is a logger warning message
2015-05-21 17:47:50,292 - log.py[line:31] - ERROR: this is a logger error message
2015-05-21 17:47:50,293 - log.py[line:32] - CRITICAL: this is a logger critical message
```


【解析】

可以发现，实现这个功能一共分5步：

第一步，创建一个logger；第二步，创建一个handler，用于写入日志文件；第三步，再创建一个handler，用于输出到控制台；第四步，定义handler的输出格式；第五步，将logger添加到handler里面。这段代码里面提到了好多概念，包括：Logger，Handler，Formatter。后面讲对这些概念进行讲解。

##  3 多文件输出

```python
# 定义文件
file_1_1 = logging.FileHandler('l1_1.log', 'a', encoding='utf-8')
fmt = logging.Formatter(fmt="%(asctime)s - %(name)s - %(levelname)s -%(module)s:  %(message)s")
file_1_1.setFormatter(fmt)

file_1_2 = logging.FileHandler('l1_2.log', 'a', encoding='utf-8')
fmt = logging.Formatter()
file_1_2.setFormatter(fmt)

# 定义日志
logger1 = logging.Logger('s1', level=logging.ERROR)
logger1.addHandler(file_1_1)
logger1.addHandler(file_1_2)


# 写日志
logger1.critical('1111')

日志一
```

和main.py

```python
# 定义文件
file_2_1 = logging.FileHandler('l2_1.log', 'a')
fmt = logging.Formatter()
file_2_1.setFormatter(fmt)

# 定义日志
logger2 = logging.Logger('s2', level=logging.INFO)
logger2.addHandler(file_2_1)

日志（二）
```

## 4 日志格式说明

logging.basicConfig函数中，可以指定日志的输出格式format，这个参数可以输出很多有用的信息，如上例所示：
```
%(levelno)s: 打印日志级别的数值
%(levelname)s: 打印日志级别名称
%(pathname)s: 打印当前执行程序的路径，其实就是sys.argv[0]
%(filename)s: 打印当前执行程序名
%(funcName)s: 打印日志的当前函数
%(lineno)d: 打印日志的当前行号
%(asctime)s: 打印日志的时间
%(thread)d: 打印线程ID
%(threadName)s: 打印线程名称
%(process)d: 打印进程ID
%(message)s: 打印日志信息
```
我在工作中给的常用格式在前面已经看到了。就是：

```
format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s'
```

这个格式可以输出日志的打印时间，是哪个模块输出的，输出的日志级别是什么，以及输入的日志内容。


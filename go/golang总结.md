**golang**

[TOC]

**MAC 调试工具安装**

`https://github.com/go-delve/delve/blob/master/Documentation/installation/osx/install.md`

```
xcode-select --install
go get -u github.com/go-delve/delve/cmd/dlv
```



# golang语言特性

- 垃圾回收

  - 内存自动回收
  - 开发专注于业务实现
  - 只需要new分配内存，不需要释放内存

- 天然并发

  - 从语言层面支持并发，非常简单

  - goroute，轻量级线程，创建多个线程

  - 基于CSP(Communicating Sequential Proccess )模型

    [Golang CSP并发模型](https://www.jianshu.com/p/36e246c6153d)

- channel

  - 管道 类似unix/linux 中的pipe
  - 多个goroute之间通过channel进行通信
  - 支持任何类型
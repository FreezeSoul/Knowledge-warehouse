1. 监控主机多，性能跟不上，延迟大
2. 多机房，防火墙 问题

- 主动模式
- 被动模式（默认）



Queue里有大量的延迟

监控主机超过300+

修改配置文件：

```
StartAgents=0
ServerActive=<master地址>

Hostname=<主机标志>
```


# kubernetes 资源控制总结

[TOC]

## kubernetes 资源控制的几种方式

k8s 可以通过以下几种方式进行资源控制

1. pod.spec.containers.resources
2. limitranges
3. resource quotas
4. storagelimits

##pod.spec.containers.resources

## limitranges

[官网地址](https://kubernetes.io/docs/concepts/policy/limit-range/)

limitranges 可以对cpu、内存 进行资源限制。

limitranges 有两种type ：Pod与 Container。

limitranges 的作用范围为namespace 下的资源，资源类型由type 决定。

limitranges 对资源的控制有五种方式：

- max ：资源空闲时 最大的资源使用量
- min：资源空闲时 最小的资源使用量
- default：一般情况下最大使用量
- default request：一般情况下最小使用量

- maxLimitRequestRatio：最小/最大 使用量的比率。

**Pod 不适用于 default 与 default request。Container 适用于所有的资源控制方式。**

当namespace 中的containers 没有配置resources 资源限制，则使用limitranges的策略。

如果namespace 中的资源配置了resources 资源限制的配置，则需要满足以下规则

```
limitranges type 为container:
min <= resource 资源限制 <= max

limitranges type 为Pod:
min <= pod 中所有container的resource 资源限制之和 <= max
```

**limitrange 控制策略在Pod Admission 阶段生效，对于在running 的pod不生效**

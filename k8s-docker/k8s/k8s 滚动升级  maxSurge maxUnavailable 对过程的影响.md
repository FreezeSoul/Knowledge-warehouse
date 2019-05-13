## k8s 滚动升级  maxSurge maxUnavailable 对过程的影响

```
new rs desire + old rs desire <= replic + maxSurge

new rs running + new rs >= replic - maxUnavailable
```



案例

```
nginx-54cd8b4545   5     0     0     0s
nginx-64bbd8bbfc   8     10    10    35s
nginx-54cd8b4545   7     0     0     0s
nginx-64bbd8bbfc   8     10    10    35s
nginx-54cd8b4545   7     0     0     0s
nginx-64bbd8bbfc   8     8     8     35s
nginx-54cd8b4545   7     5     0     0s
nginx-54cd8b4545   7     7     0     0s
nginx-54cd8b4545   7     7     1     3s
nginx-64bbd8bbfc   7     8     8     38s
nginx-54cd8b4545   8     7     1     3s
nginx-64bbd8bbfc   7     8     8     38s
nginx-54cd8b4545   8     7     1     3s
nginx-64bbd8bbfc   7     7     7     38s
nginx-54cd8b4545   8     8     1     3s
nginx-54cd8b4545   8     8     2     3s
nginx-64bbd8bbfc   6     7     7     38s
nginx-54cd8b4545   9     8     2     3s
nginx-64bbd8bbfc   6     7     7     38s
nginx-54cd8b4545   9     8     2     3s
nginx-64bbd8bbfc   6     6     6     38s
nginx-54cd8b4545   9     9     2     3s
nginx-54cd8b4545   9     9     3     4s
nginx-64bbd8bbfc   5     6     6     39s
nginx-64bbd8bbfc   5     6     6     39s
nginx-54cd8b4545   10    9     3     4s
nginx-64bbd8bbfc   5     5     5     39s
nginx-54cd8b4545   10    9     3     4s
nginx-54cd8b4545   10    10    3     4s
nginx-54cd8b4545   10    10    4     5s
nginx-64bbd8bbfc   4     5     5     40s
nginx-64bbd8bbfc   4     5     5     40s
nginx-64bbd8bbfc   4     4     4     40s
nginx-54cd8b4545   10    10    5     5s
nginx-64bbd8bbfc   3     4     4     40s
nginx-64bbd8bbfc   3     4     4     40s
nginx-64bbd8bbfc   3     3     3     40s
nginx-54cd8b4545   10    10    6     6s
nginx-64bbd8bbfc   2     3     3     41s
nginx-64bbd8bbfc   2     3     3     41s
nginx-64bbd8bbfc   2     2     2     41s
nginx-54cd8b4545   10    10    7     8s
nginx-64bbd8bbfc   1     2     2     43s
nginx-64bbd8bbfc   1     2     2     43s
nginx-64bbd8bbfc   1     1     1     43s
nginx-54cd8b4545   10    10    8     10s
nginx-64bbd8bbfc   0     1     1     45s
nginx-64bbd8bbfc   0     1     1     45s
nginx-64bbd8bbfc   0     0     0     45s
nginx-54cd8b4545   10    10    9     10s
nginx-54cd8b4545   10    10    10    10s
```

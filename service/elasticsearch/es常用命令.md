```
集群健康状况
curl 127.0.0.1:9200/_cat/health?v
获取所有index
curl 127.0.0.1:9200/_cat/indices?v
删除所有index
curl  127.0.0.1:9200/_cat/indices|awk '{print $3}'|xargs -i curl -XDELETE "127.0.0.1:9200/{}"
```


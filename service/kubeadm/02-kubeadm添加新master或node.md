# 02-kubeadm添加新master或node

一、master上生成新的token

```csharp
kubeadm token create --print-join-command
```

**执行结果**

```
[root@cn-hongkong nfs]# kubeadm token create --print-join-command
kubeadm join 172.31.182.156:8443 --token ortvag.ra0654faci8y8903   --discovery-token-ca-cert-hash sha256:04755ff1aa88e7db283c85589bee31fabb7d32186612778e53a536a297fc9010
```

二、在master上生成用于新master加入的证书

```csharp
kubeadm init phase upload-certs --experimental-upload-certs
```

**执行结果**

```
[root@cn-hongkong k8s_yaml]# init phase upload-certs --experimental-upload-certs 
[upload-certs] Storing the certificates in ConfigMap "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
f8d1c027c01baef6985ddf24266641b7c64f9fd922b15a32fce40b6b4b21e47d
```


三、添加新node

```csharp
kubeadm join 172.31.182.156:8443 --token ortvag.ra0654faci8y8903     --discovery-token-ca-cert-hash sha256:04755ff1aa88e7db283c85589bee31fabb7d32186612778e53a536a297fc9010 
```

 四、添加新master，把红色部分加到--experimental-control-plane --certificate-key后。

```csharp
  kubeadm join 172.31.182.156:8443  --token ortvag.ra0654faci8y8903 \
    --discovery-token-ca-cert-hash sha256:04755ff1aa88e7db283c85589bee31fabb7d32186612778e53a536a297fc9010 \
    --experimental-control-plane --certificate-key f8d1c027c01baef6985ddf24266641b7c64f9fd922b15a32fce40b6b4b21e47d
```

 
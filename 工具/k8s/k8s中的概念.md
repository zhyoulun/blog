### ReplicationController

现在已经不推荐使用ReplicationController，新的方案是ReplicaSet和Deployment

ReplicationController 确保在任何时候都有特定数量的 Pod 副本处于运行状态。 换句话说，ReplicationController 确保一个 Pod 或一组同类的 Pod 总是可用的。

### ReplicaSet

ReplicaSet 的目的是维护一组在任何时候都处于运行状态的 Pod 副本的稳定集合。 因此，它通常用来保证给定数量的、完全相同的 Pod 的可用性。

Deployment 是一个更高级的概念，它管理 ReplicaSet，并向 Pod 提供声明式的更新以及许多其他有用的功能。 因此，我们建议使用 Deployment 而不是直接使用 ReplicaSet，除非 你需要自定义更新业务流程或根本不需要更新。

### Deployments

### Persistent Volume

Volume是定义在Pod上的，属于“计算资源”的一部分，而实际上，“网络存储”是相对于“计算资源”而存在的一种实体资源。比如在使用虚拟机的情况下，我们通常会先定义一个网络存储，然后从中划出一个“网盘”并挂接到虚拟机上。Persistent Volume和与之相关联的Persistent Volume Claim也起到了类似的作用。

PV可以理解为k8s集群中的某个网络存储中对应的一块存储，它与Volume类似，但有一下区别：

- PV只能是网络存储，不属于任何Node，但可以在每个Node上访问
- PV并不定义在Pod上，而是独立于Pod之外定义



### 参考

- pod
- deployment
- replica set
- replication controller：副本控制器
- ingress
- service

- 工作负载资源
  - deployment
  - replicaSet
  - StatefulSets
  - DaemonSet
  - Jobs
  - 垃圾搜集
  - 已完成资源的TTL控制器
  - CronJob
  - ReplicationController

## 参考

- [工作负载资源](https://kubernetes.io/zh/docs/concepts/workloads/controllers/)

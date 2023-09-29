- 原地升级：https://openkruise.io/zh/docs/core-concepts/inplace-update
- 术语：https://github.com/openkruise/kruise/blob/master/README-zh_CN.md

通用工作负载能帮助你管理 stateless(无状态)、stateful(有状态)、daemon 类型和作业类的应用。

它们不仅支持类似于 Kubernetes 原生 Workloads 的基础功能，还提供了如 原地升级、可配置的扩缩容/发布策略、并发操作 等。

Kruise通过SidecarSet简化了Sidecar的注入， 并提供了sidecar原地升级的能力。另外， Kruise提供了增强的sidecar启动、退出的控制

- 高级工作负载
    - CloneSet - 无状态应用
    - Advanced StatefulSet - 有状态应用
    - Advanced DaemonSet - daemon 类型应用
    - BroadcastJob - 部署任务到一批特定节点上
    - AdvancedCronJob - 周期性地创建 Job 或 BroadcastJob
- Sidecar 容器管理
    - SidecarSet - 定义和升级你的 sidecar 容器
    - Container Launch Priority 控制sidecar启动顺序
    - Sidecar Job Terminator 当 Job 类 Pod 主容器退出后，Terminator Sidecar容器
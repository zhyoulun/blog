```
/opt/k8s/bin/kube-scheduler \
	--config=/etc/kubernetes/kube-scheduler.yaml \
	--bind-address=192.168.56.101 \
	--secure-port=10259 \
	--port=0 \
	--tls-cert-file=/etc/kubernetes/cert/kube-scheduler.pem \
	--tls-private-key-file=/etc/kubernetes/cert/kube-scheduler-key.pem \
	--authentication-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \
	--client-ca-file=/etc/kubernetes/cert/ca.pem \
	--requestheader-allowed-names= \
	--requestheader-client-ca-file=/etc/kubernetes/cert/ca.pem \
	--requestheader-extra-headers-prefix=X-Remote-Extra- \
	--requestheader-group-headers=X-Remote-Group \
	--requestheader-username-headers=X-Remote-User \
	--authorization-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \
	--logtostderr=true \
	--v=2
```

```
# cat /etc/kubernetes/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1alpha1
kind: KubeSchedulerConfiguration
bindTimeoutSeconds: 600
clientConnection:
  burst: 200
  kubeconfig: "/etc/kubernetes/kube-scheduler.kubeconfig"
  qps: 100
enableContentionProfiling: false
enableProfiling: true
hardPodAffinitySymmetricWeight: 1
healthzBindAddress: 192.168.56.101:10251
leaderElection:
  leaderElect: true
metricsBindAddress: 192.168.56.101:10251
```

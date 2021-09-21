### cpu相关

- Busy System: `sum by (instance)(rate(node_cpu_seconds_total{mode="system",instance="$node",job="$job"}[$__rate_interval])) * 100`
- Busy User: `sum by (instance)(rate(node_cpu_seconds_total{mode='user',instance="$node",job="$job"}[$__rate_interval])) * 100`
- Busy Iowait: `sum by (instance)(rate(node_cpu_seconds_total{mode='iowait',instance="$node",job="$job"}[$__rate_interval])) * 100`
- Busy IRQs: `sum by (instance)(rate(node_cpu_seconds_total{mode=~".*irq",instance="$node",job="$job"}[$__rate_interval])) * 100`
- Busy Other: `sum (rate(node_cpu_seconds_total{mode!='idle',mode!='user',mode!='system',mode!='iowait',mode!='irq',mode!='softirq',instance="$node",job="$job"}[$__rate_interval])) * 100`
- Idle: `sum by (mode)(rate(node_cpu_seconds_total{mode='idle',instance="$node",job="$job"}[$__rate_interval])) * 100`

```
node_cpu_seconds_total{cpu="38",mode="idle"} 9.18887195e+06
node_cpu_seconds_total{cpu="38",mode="iowait"} 683967.66
node_cpu_seconds_total{cpu="38",mode="irq"} 0
node_cpu_seconds_total{cpu="38",mode="nice"} 0
node_cpu_seconds_total{cpu="38",mode="softirq"} 55211.29
node_cpu_seconds_total{cpu="38",mode="steal"} 3109.59
node_cpu_seconds_total{cpu="38",mode="system"} 238605.15
node_cpu_seconds_total{cpu="38",mode="user"} 400166.95
```
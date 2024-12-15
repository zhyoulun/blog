## overview

https://prometheus.io/docs/introduction/overview/

Prometheus的系统架构

![](/static/images/2411/p002.png)

When does it not fit?
Prometheus values reliability. You can always view what statistics are available about your system, even under failure conditions. If you need 100% accuracy, such as for per-request billing, Prometheus is not a good choice as the collected data will likely not be detailed and complete enough. In such a case you would be best off using some other system to collect and analyze the data for billing, and Prometheus for the rest of your monitoring.

Prometheus不适合用于计费场景

## tsdb数据结构

https://github.com/prometheus/prometheus/blob/release-3.0/tsdb/docs/format/README.md


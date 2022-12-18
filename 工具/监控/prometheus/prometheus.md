### prometheus 原生支持influxdb的远程读写

- https://www.influxdata.com/blog/influxdb-now-supports-prometheus-remote-read-write-natively/

```
# Remote write configuration (for Graphite, OpenTSDB, or InfluxDB).
remote_write:
- url: "http://localhost:8086/api/v1/prom/write?u=paul&p=foo&db=prometheus"
# Remote read configuration (for InfluxDB only at the moment).
remote_read:
- url: "http://localhost:8086/api/v1/prom/read?u=paul&p=foo&db=prometheus"
```
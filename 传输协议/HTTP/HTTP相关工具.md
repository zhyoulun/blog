### http3check

- https://http3check.net/
- 检查网站是否支持http3

### http压测工具列表

- https://github.com/denji/awesome-http-benchmark


### vegeta

- https://github.com/tsenart/vegeta

```
echo "GET http://localhost/" | vegeta attack -duration=5s | tee results.bin | vegeta report
vegeta report -type=json results.bin > metrics.json
cat results.bin | vegeta plot > plot.html
cat results.bin | vegeta report -type="hist[0,100ms,200ms,300ms]"
```

### LB性能压测对比报告

- https://github.com/gaplo917/load-balancer-benchmark/blob/master/bench
- 压测工具：https://github.com/codesenberg/bombardier


## client_golang内置指标

![](/static/images/2411/p001.png)

其他可以额外的使用的内置指标

```golang
prometheus.MustRegister(collectors.NewBuildInfoCollector())
```

## 自定义指标

示例代码

```golang
package main

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"log"
	"net/http"
	"time"
)

var (
	testGauge = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "test_gauge",
		Help: "test gauge",
	})
	testCounter = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "test_counter",
		Help: "test counter",
	})
)

func Init() error {
	if err := prometheus.Register(testGauge); err != nil {
		return err
	}
	if err := prometheus.Register(testCounter); err != nil {
		return err
	}
	return nil
}

func GenData() {
	//testGauge
	go func() {
		t := time.NewTicker(time.Second)
		for v := range t.C {
			testGauge.Set(float64(v.Second()))
		}
	}()

	//testCounter
	go func() {
		t := time.NewTicker(time.Second)
		for range t.C {
			testCounter.Add(1)
		}
	}()
}

func main() {
	if err := Init(); err != nil {
		panic(err)
	}

	GenData()

	http.Handle("/metrics", promhttp.Handler())
	log.Fatal(http.ListenAndServe("127.0.0.1:8081", nil))
}
```

测试

```
http://127.0.0.1:8081/metrics
```

```
# HELP test_counter test counter
# TYPE test_counter counter
test_counter 67
# HELP test_gauge test gauge
# TYPE test_gauge gauge
test_gauge 4
```

## 参考

- [prometheus client_golang使用](https://www.cnblogs.com/gaorong/p/7881203.html)

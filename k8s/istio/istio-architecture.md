- https://istio.io/latest/docs/ops/deployment/architecture/


An Istio service mesh is logically split into a data plane and a control plane.

- The data plane is composed of a set of intelligent proxies (Envoy) deployed as sidecars. These proxies mediate and control all network communication between microservices. They also collect and report telemetry on all mesh traffic.
- The control plane manages and configures the proxies to route traffic.

The following diagram shows the different components that make up each plane:

![](/static/images/2308/p001.svg)
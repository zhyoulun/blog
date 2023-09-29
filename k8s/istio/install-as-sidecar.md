- https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/

In order to take advantage of all of Istio’s features, pods in the mesh must be running an Istio sidecar proxy.

When you set the istio-injection=enabled label on a namespace and the injection webhook is enabled, any new pods that are created in that namespace will automatically have a sidecar added to them.


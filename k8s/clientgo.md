### audit日志示例

```json
{
  "kind": "Event",
  "apiVersion": "audit.k8s.io/v1",
  "level": "Request",
  "auditID": "ad2599de-71d8-4b7c-a04c-2fab2f988e67",
  "stage": "ResponseComplete",
  "requestURI": "/api/v1/pods",
  "verb": "list",
  "user": {
    "username": "admin",
    "groups": [
      "system:masters",
      "system:authenticated"
    ]
  },
  "sourceIPs": [
    "192.168.56.1"
  ],
  "userAgent": "___go_build_github_com_zhyoulun_go_study_clientgo/v0.0.0 (darwin/amd64) kubernetes/$Format",
  "objectRef": {
    "resource": "pods",
    "apiVersion": "v1"
  },
  "responseStatus": {
    "metadata": {},
    "code": 200
  },
  "requestReceivedTimestamp": "2022-09-04T08:30:29.306472Z",
  "stageTimestamp": "2022-09-04T08:30:29.340919Z",
  "annotations": {
    "authorization.k8s.io/decision": "allow",
    "authorization.k8s.io/reason": ""
  }
}
```

### 测试代码

代码来自：

- https://github.com/kubernetes/client-go/blob/master/examples/out-of-cluster-client-configuration/main.go
- https://github.com/kubernetes/client-go/blob/master/examples/in-cluster-client-configuration/main.go

`main.go`

```go
package main

import (
	"context"
	"fmt"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"time"
)

func main() {
	kubeconfig := "/Users/zhangyoulun/Downloads/dev-config"
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		panic(err.Error())
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}

	for {
		pods, err := clientset.CoreV1().Pods("kubernetes-dashboard").List(context.TODO(), v1.ListOptions{})
		if err != nil {
			panic(err.Error())
		}
		fmt.Printf("there are %d pods in the cluster\n", len(pods.Items))

		time.Sleep(10 * time.Second)
	}
}
```

`go.mod`

```go
module github.com/zhyoulun/go-study/clientgo

go 1.19

require (
	k8s.io/apimachinery v0.25.0
	k8s.io/client-go v0.25.0
	github.com/PuerkitoBio/purell v1.1.1 // indirect
	github.com/PuerkitoBio/urlesc v0.0.0-20170810143723-de5bf2ad4578 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/emicklei/go-restful/v3 v3.8.0 // indirect
	github.com/go-logr/logr v1.2.3 // indirect
	github.com/go-openapi/jsonpointer v0.19.5 // indirect
	github.com/go-openapi/jsonreference v0.19.5 // indirect
	github.com/go-openapi/swag v0.19.14 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/golang/protobuf v1.5.2 // indirect
	github.com/google/gnostic v0.5.7-v3refs // indirect
	github.com/google/gofuzz v1.1.0 // indirect
	github.com/imdario/mergo v0.3.6 // indirect
	github.com/josharian/intern v1.0.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/mailru/easyjson v0.7.6 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	golang.org/x/net v0.0.0-20220722155237-a158d28d115b // indirect
	golang.org/x/oauth2 v0.0.0-20211104180415-d3ed0bb246c8 // indirect
	golang.org/x/sys v0.0.0-20220722155257-8c9f86f7a55f // indirect
	golang.org/x/term v0.0.0-20210927222741-03fcf44c2211 // indirect
	golang.org/x/text v0.3.7 // indirect
	golang.org/x/time v0.0.0-20220210224613-90d013bbcef8 // indirect
	google.golang.org/appengine v1.6.7 // indirect
	google.golang.org/protobuf v1.28.0 // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	k8s.io/api v0.25.0 // indirect
	k8s.io/klog/v2 v2.70.1 // indirect
	k8s.io/kube-openapi v0.0.0-20220803162953-67bda5d908f1 // indirect
	k8s.io/utils v0.0.0-20220728103510-ee6ede2d64ed // indirect
	sigs.k8s.io/json v0.0.0-20220713155537-f223a00ba0e2 // indirect
	sigs.k8s.io/structured-merge-diff/v4 v4.2.3 // indirect
	sigs.k8s.io/yaml v1.2.0 // indirect
)
```

### 结构体

代码来自：https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/apiserver/pkg/apis/audit/v1/types.go

```go
type TypeMeta struct {
	// Kind is a string value representing the REST resource this object represents.
	// Servers may infer this from the endpoint the client submits requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	// +optional
	Kind string `json:"kind,omitempty" protobuf:"bytes,1,opt,name=kind"`

	// APIVersion defines the versioned schema of this representation of an object.
	// Servers should convert recognized schemas to the latest internal value, and
	// may reject unrecognized values.
	// More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	// +optional
	APIVersion string `json:"apiVersion,omitempty" protobuf:"bytes,2,opt,name=apiVersion"`
}

// Event captures all the information that can be included in an API audit log.
type Event struct {
	metav1.TypeMeta `json:",inline"`

	// AuditLevel at which event was generated
	Level Level `json:"level" protobuf:"bytes,1,opt,name=level,casttype=Level"`

	// Unique audit ID, generated for each request.
	AuditID types.UID `json:"auditID" protobuf:"bytes,2,opt,name=auditID,casttype=k8s.io/apimachinery/pkg/types.UID"`
	// Stage of the request handling when this event instance was generated.
	Stage Stage `json:"stage" protobuf:"bytes,3,opt,name=stage,casttype=Stage"`

	// RequestURI is the request URI as sent by the client to a server.
	RequestURI string `json:"requestURI" protobuf:"bytes,4,opt,name=requestURI"`
	// Verb is the kubernetes verb associated with the request.
	// For non-resource requests, this is the lower-cased HTTP method.
	Verb string `json:"verb" protobuf:"bytes,5,opt,name=verb"`
	// Authenticated user information.
	User authnv1.UserInfo `json:"user" protobuf:"bytes,6,opt,name=user"`
	// Impersonated user information.
	// +optional
	ImpersonatedUser *authnv1.UserInfo `json:"impersonatedUser,omitempty" protobuf:"bytes,7,opt,name=impersonatedUser"`
	// Source IPs, from where the request originated and intermediate proxies.
	// +optional
	SourceIPs []string `json:"sourceIPs,omitempty" protobuf:"bytes,8,rep,name=sourceIPs"`
	// UserAgent records the user agent string reported by the client.
	// Note that the UserAgent is provided by the client, and must not be trusted.
	// +optional
	UserAgent string `json:"userAgent,omitempty" protobuf:"bytes,16,opt,name=userAgent"`
	// Object reference this request is targeted at.
	// Does not apply for List-type requests, or non-resource requests.
	// +optional
	ObjectRef *ObjectReference `json:"objectRef,omitempty" protobuf:"bytes,9,opt,name=objectRef"`
	// The response status, populated even when the ResponseObject is not a Status type.
	// For successful responses, this will only include the Code and StatusSuccess.
	// For non-status type error responses, this will be auto-populated with the error Message.
	// +optional
	ResponseStatus *metav1.Status `json:"responseStatus,omitempty" protobuf:"bytes,10,opt,name=responseStatus"`

	// API object from the request, in JSON format. The RequestObject is recorded as-is in the request
	// (possibly re-encoded as JSON), prior to version conversion, defaulting, admission or
	// merging. It is an external versioned object type, and may not be a valid object on its own.
	// Omitted for non-resource requests.  Only logged at Request Level and higher.
	// +optional
	RequestObject *runtime.Unknown `json:"requestObject,omitempty" protobuf:"bytes,11,opt,name=requestObject"`
	// API object returned in the response, in JSON. The ResponseObject is recorded after conversion
	// to the external type, and serialized as JSON.  Omitted for non-resource requests.  Only logged
	// at Response Level.
	// +optional
	ResponseObject *runtime.Unknown `json:"responseObject,omitempty" protobuf:"bytes,12,opt,name=responseObject"`
	// Time the request reached the apiserver.
	// +optional
	RequestReceivedTimestamp metav1.MicroTime `json:"requestReceivedTimestamp" protobuf:"bytes,13,opt,name=requestReceivedTimestamp"`
	// Time the request reached current audit stage.
	// +optional
	StageTimestamp metav1.MicroTime `json:"stageTimestamp" protobuf:"bytes,14,opt,name=stageTimestamp"`

	// Annotations is an unstructured key value map stored with an audit event that may be set by
	// plugins invoked in the request serving chain, including authentication, authorization and
	// admission plugins. Note that these annotations are for the audit event, and do not correspond
	// to the metadata.annotations of the submitted object. Keys should uniquely identify the informing
	// component to avoid name collisions (e.g. podsecuritypolicy.admission.k8s.io/policy). Values
	// should be short. Annotations are included in the Metadata level.
	// +optional
	Annotations map[string]string `json:"annotations,omitempty" protobuf:"bytes,15,rep,name=annotations"`
}
```

### 字段说明 - Level

```go
// LevelNone disables auditing
LevelNone Level = "None"
// LevelMetadata provides the basic level of auditing.
LevelMetadata Level = "Metadata"
// LevelRequest provides Metadata level of auditing, and additionally
// logs the request object (does not apply for non-resource requests).
LevelRequest Level = "Request"
// LevelRequestResponse provides Request level of auditing, and additionally
// logs the response object (does not apply for non-resource requests).
LevelRequestResponse Level = "RequestResponse"
```

### 字段说明 - Stage

```go
const (
	// The stage for events generated as soon as the audit handler receives the request, and before it
	// is delegated down the handler chain.
	StageRequestReceived = "RequestReceived"
	// The stage for events generated once the response headers are sent, but before the response body
	// is sent. This stage is only generated for long-running requests (e.g. watch).
	StageResponseStarted = "ResponseStarted"
	// The stage for events generated once the response body has been completed, and no more bytes
	// will be sent.
	StageResponseComplete = "ResponseComplete"
	// The stage for events generated when a panic occurred.
	StagePanic = "Panic"
)
```

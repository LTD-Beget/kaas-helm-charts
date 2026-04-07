{{- define "in-cloud-capi-template.patches.clusterTemplate.wrapper.default" -}}
  {{- with $.Values.capi.k8s -}}
    {{- $clusterInfrastructureTemplate  := index .clusterInfrastructureTemplate .infrastructureType }}
- selector:
    apiVersion: {{ $clusterInfrastructureTemplate.apiVersion }}
    kind: {{ $clusterInfrastructureTemplate.kind }}
    matchResources:
      infrastructureCluster: true
  jsonPatches:
    - op: replace
      path: /spec/template/spec/customerLogin
      valueFrom:
        variable: {{ $.Values.companyPrefix}}ClusterCustomerLogin
    - op: replace
      path: /spec/template/spec/region
      valueFrom:
        variable: {{ $.Values.companyPrefix}}ClusterRegion
    - op: replace
      path: /spec/template/spec/loadBalancerSpec/name
      valueFrom:
        variable: builtin.cluster.name
    - op: replace
      path: /spec/template/spec/loadBalancerSpec/displayName
      valueFrom:
        variable: builtin.cluster.name
    - op: replace
      path: /spec/template/spec/loadBalancerSpec/listener/internal
      valueFrom:
        variable: {{ $.Values.companyPrefix}}ClusterLoadBalancerListenerInternal
    - op: replace
      path: /spec/template/spec/loadBalancerSpec/healthcheck/healthcheckThreshold
      valueFrom:
        variable: {{ $.Values.companyPrefix}}ClusterLoadBalancerHealthcheckThreshold
    - op: replace
      path: /spec/template/spec/loadBalancerSpec/healthcheck/healthcheckIntervalSec
      valueFrom:
        variable: {{ $.Values.companyPrefix}}ClusterLoadBalancerHealthcheckIntervalSec
    - op: replace
      path: /spec/template/spec/loadBalancerSpec/healthcheck/healthcheckTimeoutSec
      valueFrom:
        variable: {{ $.Values.companyPrefix}}ClusterLoadBalancerHealthcheckTimeoutSec
    - op: replace
      path: /spec/template/spec/loadBalancerSpec/listener/ports
      valueFrom:
        variable: {{ $.Values.companyPrefix}}ClusterLoadBalancerListenerPorts
    - op: replace
      path: /spec/template/spec/loadBalancerSpec/loadBalancerType
      valueFrom:
        variable: {{ $.Values.companyPrefix}}ClusterLoadBalancerType
  {{- end -}}
{{- end -}}

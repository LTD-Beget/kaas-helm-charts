{{- define "in-cloud-capi-template.patches.clusterTemplate.wrapper.clientAttributes" -}}
- op: add
  path: /spec/template/spec/loadBalancerSpec/listener/address
  valueFrom:
    variable: {{ $.Values.companyPrefix}}ClusterLoadBalancerListenerAddress
{{- end -}}

{{- define "in-cloud-capi-template.patches.clusterTemplate.wrapper.client" -}}
    {{- (include "in-cloud-capi-template.patches.clusterTemplate.wrapper.default"  $ | nindent 0  ) }}
    {{- (include "in-cloud-capi-template.patches.clusterTemplate.wrapper.clientAttributes"  $ | nindent 4  ) }}
{{- end -}}

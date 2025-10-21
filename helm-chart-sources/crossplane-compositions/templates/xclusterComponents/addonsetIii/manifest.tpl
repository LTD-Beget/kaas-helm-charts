{{- define "xclusterComponents.addonsetIii" -}}
  {{- include "xclusterComponents.variables" . | nindent 0 }}
  {{ printf `

{{- $xAddonSetReady                     := "False" }}

{{- with .observed.resources.xAddonSet }}
  {{- range (dig "resource" "status" "conditions" (list) . )}}
    {{- if and (eq .type "Ready") (eq .status "True") }}
      {{- $xAddonSetReady = "True" }}
    {{- end }}
  {{- end }}
{{- end }}

apiVersion: in-cloud.io/v1alpha1
kind: XAddonSet
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: xAddonSet
  name: {{ $clusterName }}-addonset-iii
spec:
  current:
    providerConfigRef:
      name: default
  common:
    argocd:
      destination:
        name: {{ $clusterName }}
      project: default
      namespace: {{ $argocdDestinationNamespace }}
      providerConfigRef:
        name: default
    cluster:
      name: {{ $clusterName }}
      host: {{ $clusterHost }}
      port: {{ $clusterPort }}
    namespace: {{ $namespace }}
    providerConfigRef:
      name: default
    trackingID: {{ $trackingID }}
    xcluster: {{ $xcluster }}` -}}
{{- end }}

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

### extra variables
{{ $infraVMOperatorReady := false }}
{{ $istioBaseReady := false }}
###


apiVersion: in-cloud.io/v1alpha1
kind: XAddonSet
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: xAddonSet
    {{- if eq $xAddonSetReady "True" }}
    gotemplating.fn.crossplane.io/ready: "True"
    status.in-cloud.io/ready: {{ $xAddonSetReady | quote }}
    {{- end }}
  name: {{ $clusterName }}-addonset-iii
spec:
  common:
    argocd:
      destination:
        name: {{ $clusterName }}
      project: default
      namespace: {{ $argocdDestinationNamespace }}
    cluster:
      name: {{ $clusterName }}
      host: {{ $clusterHost }}
      port: {{ $clusterPort }}
    providerConfigRef:
      name: default
    {{- if $trackingID }}
    trackingID: {{ $trackingID }}
    {{- end }}
    xcluster: {{ $xcluster }}
  addons:` -}}
    {{ include "xclusterComponents.addonsetIii.helmInserterTest" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.certManager" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.dex" . | nindent 4 }}
{{- end }}

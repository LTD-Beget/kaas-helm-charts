{{- define "xclusterComponents.addonsetIii" -}}
  {{- include "xcertificateset.variables" . | nindent 0 }}
  {{ printf `

{{- $xAddonSetReady                     := "False" }}

{{- with .observed.resources.xAddonSet }}
  {{- range (dig "resource" "status" "conditions" (list) . )}}
    {{- if and (eq .type "Ready") (eq .status "True") }}
      {{- $xAddonSetReady = "True" }}
    {{- end }}
  {{- end }}
{{- end }}

###extra variables

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
    argocd.argoproj.io/tracking-id: {{ $trackingID }}
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
    xcluster: {{ $xcluster }}
  addons:` -}}
    {{ include "xclusterComponents.addonsetIii.helmInserterTest" . | nindent 4 }}
{{- end }}

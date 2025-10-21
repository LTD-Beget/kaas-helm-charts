{{- define "xclusterComponents.addonsetIii" -}}
  {{ printf `
{{- $environment                      := index .context "apiextensions.crossplane.io/environment" }}

{{- $clusterName                        := $environment.infra.name }}
{{- $clusterHost                        := $environment.infra.host }}
{{- $clusterPort                        := $environment.infra.port }}
{{- $infraKubernetesProviderConfigName  := $environment.infra.kubernetesProviderConfig.name }}
{{- $trackingID                         := $environment.trackingID }}
{{- $systemEnabled                      := $environment.system.enabled | default false }}
{{- $systemName                         := $environment.system.name }}
{{- $systemNamespace                    := $environment.system.namespace }}
{{- $systemProjectName                  := $environment.system.project.name }}
{{- $systemProjectObjectName            := $environment.system.project.object.name }}
{{- $infraClusterReady                  := "False" }}
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
  name: {{ $clusterName }}-after-available
spec:
  current:
    providerConfigRef:
      name: default
  common:
    argocd:
      destination:
        name: {{ $clusterName }}
      project: {{ $systemProjectName }}
      namespace: {{ $systemNamespace }}
      providerConfigRef:
        name: default
    cluster:
      name: {{ $clusterName }}
      host: {{ $clusterHost }}
      port: {{ $clusterPort }}
    namespace: {{ $systemNamespace }}
    providerConfigRef:
      name: default
    trackingID: {{ $trackingID }}
    xcluster: {{ $systemName }}
  addons:` -}}
    {{ include "xclusterComponents.addonsetIii.helmInserterTest" . | nindent 4 }}
{{- end }}

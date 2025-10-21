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
{{ $infraVMOperatorReady    := false }}
{{ $istioBaseReady          := false }}
{{ $infraTrivyOperatorReady := false }}
{{ $controlPlaneReplicas    := 3 }}
{{ $systemEnabled           := false }}
{{ $systemNamespace         := mock }}
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
    {{ include "xclusterComponents.addonsetIii.etcdBackup" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.istiod" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.istioGw" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.incloudUi" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.trustManager" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.trivyOperator" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.grafana" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.grafanaDashboards" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.grafanaOperator" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.kubeStateMetrics" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.metricsServer" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.processExporter" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.prometheus" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.prometheusNodeExporter" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.vmAgent" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.vmAlert" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.vmAlertmanager" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.vmAlertRules" . | nindent 4 }}
  {{- printf `
    {{ if $systemEnabled }}
  ` }}
    {{ include "xclusterComponents.addonsetIii.begetCmProvider" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.capi" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.capiClusterClass" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.capiKubeadmBootstrap" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.capiKubeadmControlPlane" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.crossplaneXcluster" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.vault" . | nindent 4 }}
    {{ include "xclusterComponents.addonsetIii.vaultSecrets" . | nindent 4 }}
  {{- printf `
    {{- end }}
  ` }}

{{- end }}

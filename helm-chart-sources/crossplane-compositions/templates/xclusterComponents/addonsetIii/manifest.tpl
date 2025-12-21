{{- define "xclusterComponents.addonsetIii" -}}
  {{- include "xclusterComponents.variables" . | nindent 0 }}
  {{ printf `

{{- $xAddonSetReady                     := "False" }}
{{- $xAddonSetClientExists              := false }}

{{- with .observed.resources.xAddonSet }}
  {{- range (dig "resource" "status" "conditions" (list) . )}}
    {{- if and (eq .type "Ready") (eq .status "True") }}
      {{- $xAddonSetReady = "True" }}
    {{- end }}
  {{- end }}
{{- end }}

{{ if $systemEnabled }}
---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: istioGwSvc
    gotemplating.fn.crossplane.io/ready: "True"
  name: 'istio-gw-svc-observe'
spec:
  deletionPolicy: Orphan
  managementPolicies:
  - 'Observe'
  forProvider:
    manifest:
      apiVersion: v1
      kind: Service
      metadata:
        name: 'istio-gw'
        namespace: 'beget-istio-gw'
  watch: true
---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: systemVmInsertSvc
    gotemplating.fn.crossplane.io/ready: "True"
  name: 'vm-insert-svc-observe'
spec:
  deletionPolicy: Orphan
  managementPolicies:
  - 'Observe'
  forProvider:
    manifest:
      apiVersion: v1
      kind: Service
      metadata:
        name: 'vminsert-lb'
        namespace: 'beget-vmcluster'
  watch: true
{{ end }}

### extra variables
{{- $xAddonSetObserve            := dig "resource" "spec" "addonStatus" (dict) (get $.observed.resources "xAddonSet" | default (dict)) }}
{{- $infraVMOperatorReady        := dig "vmOperator" "deployed" false ($xAddonSetObserve) }}
{{- $istioBaseReady              := dig "istioBase" "deployed" false ($xAddonSetObserve) }}
{{- $infraTrivyOperatorReady     := dig "trivyOperator" "deployed" false ($xAddonSetObserve) }}
{{- $certManagerReady            := dig "certManager"  "deployed" false ($xAddonSetObserve) }}
{{- $corednsReady                := dig "coredns"  "deployed" false ($xAddonSetObserve) }}
{{- $argocdReady                 := dig "argocd"  "deployed" false ($xAddonSetObserve) }}
{{- $crossplaneReady             := dig "crossplane"  "deployed" false ($xAddonSetObserve) }}

{{- range (dig "resource" "status" "atProvider" "manifest" "status" "loadBalancer" "ingress" (list) (get $.observed.resources "istioGwSvc" | default (dict))) }}
  {{- if eq .ipMode "VIP" }}
    {{- $systemIstioGwVip        =  .ip }}
    {{- break }}
  {{- end }}
{{- end }}

{{- range (dig "resource" "status" "atProvider" "manifest" "status" "loadBalancer" "ingress" (list) (get $.observed.resources "systemVmInsertSvc" | default (dict))) }}
  {{- if eq .ipMode "VIP" }}
    {{- $systemVmInsertVip        =  .ip }}
    {{- break }}
  {{- end }}
{{- end }}

{{- $xRCreationTimestamp         := $.observed.composite.resource.metadata.creationTimestamp }}

{{- with .observed.resources.xAddonSetClient }}
  {{- $xAddonSetClientExists      = true }}
{{- end }}

{{- $xAddonSetClientEnabled      := or (and $clientEnabled $clientClusterReady) (and $clientEnabled $xAddonSetClientExists) }}

{{- $xAddonSetClientObserve      := dig "resource" "spec" "addonStatus" (dict) (get $.observed.resources "xAddonSetClient" | default (dict)) }}
{{- $konnectivityAgentReady      := dig "konnectivityAgent" "deployed" false ($xAddonSetClientObserve) }}
{{- $kubeadmResourcesReady       := dig "kubeadmResources"  "deployed" false ($xAddonSetClientObserve) }}

{{- $xAddonSetClientReady        := and $konnectivityAgentReady $kubeadmResourcesReady }}

{{- $remoteWriteUrlVmAgent  := printf "https://%%s:8480/insert/0/prometheus" $systemVmInsertVip }}
{{- if $systemEnabled }}
  {{- $remoteWriteUrlVmAgent = "https://vminsert-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster.svc:8480/insert/0/prometheus" }}
{{- end }}
###
---
apiVersion: in-cloud.io/v1alpha1
kind: XAddonSet
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: xAddonSet
    {{ if eq $xAddonSetReady "True" }}
    gotemplating.fn.crossplane.io/ready: "True"
    status.in-cloud.io/ready: {{ $xAddonSetReady | quote }}
    {{ end }}
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
    {{ if $trackingID }}
    trackingID: {{ $trackingID }}
    {{ end }}
    xcluster: {{ $xcluster }}
  addons:` -}}
    {{- include "xclusterComponents.addonsetIii.certManager" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.certManagerCsiDriver" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.crossplaneCompositions" . | nindent 4 }}
  {{ printf `
    {{ if or $xAddonSetClientReady (not $clientEnabled)}}
  ` -}}
    {{- include "xclusterComponents.addonsetIii.argocd" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.cilium" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.coredns" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.crossplane" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.crossplaneFunctions" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.etcdBackup" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.istioBase" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.istiod" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.istioGw" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.incloudUi" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.incloudWebResources" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.trustManager" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.metricsServer" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.processExporter" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.prometheusNodeExporter" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.vmAgent" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.helmInsVMAgentAddRbac" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.vmOperator" . | nindent 4 }}
  {{- printf `
    {{ end }}
    {{ if $systemEnabled }}
  ` }}
    {{- include "xclusterComponents.addonsetIii.helmInserter" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.begetCmProvider" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.ccm" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.csrc" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.capi" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.capiClusterClass" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.capiKubeadmBootstrap" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.capiKubeadmControlPlane" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.crossplaneXcluster" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.dex" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.trivyOperator" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.vault" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.vmAlertmanager" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.vmAlert" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.vmAlertRules" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.vmCluster" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.grafana" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.grafanaDashboards" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIii.grafanaOperator" . | nindent 4 }}
  {{- printf `
    {{ end }}
  ` }}

{{- end }}

{{- define "xclusterComponents.addonsetIic" -}}
  {{- include "xclusterComponents.variables" . | nindent 0 }}
  {{ printf `

{{- $xAddonSetReady                     := "False" }}

{{- with .observed.resources.xAddonSetClient }}
  {{- range (dig "resource" "status" "conditions" (list) . )}}
    {{- if and (eq .type "Ready") (eq .status "True") }}
      {{- $xAddonSetReady = "True" }}
    {{- end }}
  {{- end }}
{{- end }}

---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: clientCa
    gotemplating.fn.crossplane.io/ready: "True"
  name: "{{ $xcluster }}-client-ca-observe"
spec:
  deletionPolicy: Orphan
  managementPolicies:
  - 'Observe'
  forProvider:
    manifest:
      apiVersion: v1
      kind: Secret
      metadata:
        name: "{{ $xcluster }}-client-ca"
        namespace: 'beget-system'
  watch: true

{{- $clientCa = dig "resource" "status" "atProvider" "manifest" "data" "tls.crt" "" (get $.observed.resources "clientCa" | default (dict)) }}

### extra variables
{{- $xAddonSetObserve            := dig "resource" "spec" "addonStatus" (dict) (get $.observed.resources "xAddonSetClient" | default (dict)) }}
{{- $infraVMOperatorReady        := dig "vmOperator" "deployed" false ($xAddonSetObserve) }}
{{- $istioBaseReady              := dig "istioBase" "deployed" false ($xAddonSetObserve) }}
{{- $infraTrivyOperatorReady     := dig "trivyOperator" "deployed" false ($xAddonSetObserve) }}
###

---
apiVersion: in-cloud.io/v1alpha1
kind: XAddonSet
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: xAddonSetClient
    {{ if eq $xAddonSetReady "True" }}
    gotemplating.fn.crossplane.io/ready: "True"
    status.in-cloud.io/ready: {{ $xAddonSetReady | quote }}
    {{ end }}
  name: {{ $clusterClientName }}-addonset-iic
spec:
  common:
    argocd:
      destination:
        name: {{ $clusterClientName }}
      project: default
      namespace: {{ $argocdDestinationNamespace }}
    cluster:
      name: {{ $clusterClientName }}
      host: {{ $clusterHost }}
      port: {{ $clusterClientPort }}
    providerConfigRef:
      name: default
    {{ if $trackingID }}
    trackingID: {{ $trackingID }}
    {{ end }}
    xcluster: {{ $xcluster }}
  addons:` -}}
    {{- include "xclusterComponents.addonsetIic.kubeadmResources" . | nindent 4 }}
    {{- include "xclusterComponents.addonsetIic.konnectivityAgent" . | nindent 4 }}
{{- end }}

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
---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: systemClusterObserve
    gotemplating.fn.crossplane.io/ready: "True"
  name: {{ $clusterName }}-cluster
spec:
  deletionPolicy: Orphan
  managementPolicies:
  - 'Observe'
  forProvider:
    manifest:
      apiVersion: cluster.x-k8s.io/v1beta1
      kind: Cluster
      metadata:
        name: {{ $clusterName }}
        namespace: {{ $systemNamespace }}
  watch: false
{{ end }}

{{- $infraClusterEndpoint := printf "https://%%s:%%v" $clusterHost $clusterPort }}
{{- $clientClusterEndpoint := printf "https://%%s:2%%v" $clusterHost $clusterPort }}

---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  name: {{ $xcluster }}-infra-certificateset
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: InfraCertificateSet
    gotemplating.fn.crossplane.io/ready: "True"
spec:
  deletionPolicy: Orphan
  providerConfigRef:
    name: default
  forProvider:
    manifest:
      apiVersion: in-cloud.io/v1alpha1
      kind: CertificateSet
      metadata:
        labels:
          cluster.x-k8s.io/cluster-name: {{ $xcluster }}-infra
          clusterctl.cluster.x-k8s.io/move: "true"
          xcluster.in-cloud.io/name: {{ $xcluster }}
        name: {{ $xcluster }}-infra
        namespace: beget-system
      spec:
        environment: infra
        argocdCluster: true
        issuerRef:
          apiVersion: cert-manager.io/v1
          kind: ClusterIssuer
          name: selfsigned
        issuerRefOidc:
          apiVersion: cert-manager.io/v1
          kind: ClusterIssuer
          name: selfsigned-cluster-issuer
        kubeconfig: false
        kubeconfigEndpoint: {{ $infraClusterEndpoint }}

---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  name: {{ $xcluster }}-client-certificateset
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: ClientCertificateSet
    gotemplating.fn.crossplane.io/ready: "True"
spec:
  deletionPolicy: Orphan
  providerConfigRef:
    name: default
  forProvider:
    manifest:
      apiVersion: in-cloud.io/v1alpha1
      kind: CertificateSet
      metadata:
        labels:
          cluster.x-k8s.io/cluster-name: {{ $xcluster }}-client
          clusterctl.cluster.x-k8s.io/move: "true"
          xcluster.in-cloud.io/name: {{ $xcluster }}
        name: {{ $xcluster }}-client
        namespace: beget-system
      spec:
        environment: client
        argocdCluster: true
        issuerRef:
          apiVersion: cert-manager.io/v1
          kind: ClusterIssuer
          name: selfsigned
        kubeconfig: false
        kubeconfigEndpoint: {{ $clientClusterEndpoint }}

---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: ClusterIssuerEtcd
    gotemplating.fn.crossplane.io/ready: "True"
  name: etcd-ca
spec:
  ca:
    secretName: {{ $xcluster }}-infra-etcd

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
    {{- $systemVmInsertVip       =  .ip }}
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
  {{- $remoteWriteUrlVmAgent = "https://vminsert.beget-vmcluster.svc:8480/insert/0/prometheus" }}
{{- end }}
` }}
{{- include "newaddons.istioBase" . }}
{{- include "newaddons.istiod" . }}
{{- include "newaddons.crossplaneCompositions" . }}
{{- include "newaddons.certControllerManager" . }}

{{- end }}

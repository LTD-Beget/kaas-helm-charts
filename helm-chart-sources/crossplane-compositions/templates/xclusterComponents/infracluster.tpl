{{- define "xcertificateset.infracluster" -}}
  {{- include "xcertificateset.variables" . | nindent 0 }}
  {{ printf `

{{- $xCertificateSetReady    := "False" -}}
{{- range (dig "resource" "status" "conditions" (list) (get $.observed.resources "xCertificateSet" | default (dict))) }}
  {{- if eq .type "Ready" }}
    {{- $xCertificateSetReady = (.status) }}
  {{- end }}
{{- end }}

apiVersion: in-cloud.io/v1alpha1
kind: XCertificateSet
metadata:
  annotations:
    argocd.argoproj.io/tracking-id: {{ $trackingID }}
    gotemplating.fn.crossplane.io/composition-resource-name: xCertificateSet
    gotemplating.fn.crossplane.io/ready: {{ $xCertificateSetReady | quote }}
  {{- if eq $xCertificateSetReady "True" }}
    status.in-cloud.io/ready: {{ $xCertificateSetReady | quote }}
  {{- end }}
  labels:
    cluster.x-k8s.io/cluster-name: {{ $clusterName }}
  name: {{ $clusterName }}
spec:
  compositeDeletePolicy: Foreground
  common:
    labels:
      - name: "cluster.x-k8s.io/cluster-name"
        value:  {{ $clusterName }}
    annotations:
      - name: "argocd.argoproj.io/tracking-id"
        value: {{ $trackingID }}
    namespace: {{ $namespace }}
  providerConfigRef:
    name: default
  customer: {{ $customer }}
  xcertificates:
    caOidc:
      common:
        suffix: "-ca-oidc"
      certificate:
        duration: 175200h
        isCA: true
        usages:
          - cert sign
          - key encipherment
          - digital signature
  ` }}
{{- end -}}
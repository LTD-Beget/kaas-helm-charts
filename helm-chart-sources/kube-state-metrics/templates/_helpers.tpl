{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "beget-kube-state-metrics.name" -}}
{{- $ksm := index .Values "kube-state-metrics" -}}
{{- default .Chart.Name $ksm.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "beget-kube-state-metrics.fullname" -}}
{{- $ksm := index .Values "kube-state-metrics" -}}
{{- if $ksm.fullnameOverride -}}
{{- $ksm.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name $ksm.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "beget-kube-state-metrics.serviceAccountName" -}}
{{- $ksm := index .Values "kube-state-metrics" -}}
{{- if $ksm.serviceAccount.create -}}
    {{ default (include "beget-kube-state-metrics.fullname" .) $ksm.serviceAccount.name }}
{{- else -}}
    {{ default "default" $ksm.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "beget-kube-state-metrics.namespace" -}}
{{- $ksm := index .Values "kube-state-metrics" -}}
  {{- if $ksm.namespaceOverride -}}
    {{- $ksm.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "beget-kube-state-metrics.selectorLabels" }}
{{- $ksm := index .Values "kube-state-metrics" -}}
{{- if $ksm.selectorOverride }}
{{ toYaml $ksm.selectorOverride }}
{{- else }}
app.kubernetes.io/name: {{ include "beget-kube-state-metrics.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- end }}

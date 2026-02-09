{{/*
Expand the name of the chart.
*/}}
{{- define "victoria-metrics-k8s-stack.name" -}}
{{- $values := index .Values "victoria-metrics-k8s-stack" -}}
{{- default .Chart.Name $values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "victoria-metrics-k8s-stack.fullname" -}}
{{- $values := index .Values "victoria-metrics-k8s-stack" -}}
{{- if $values.fullnameOverride }}
{{- $values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name $values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "victoria-metrics-k8s-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "victoria-metrics-k8s-stack.labels" -}}
helm.sh/chart: {{ include "victoria-metrics-k8s-stack.chart" . }}
{{ include "victoria-metrics-k8s-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "victoria-metrics-k8s-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "victoria-metrics-k8s-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "wrapper-prometheus-process-exporter.name" -}}
{{- $ppx := index .Values "prometheus-process-exporter" -}}
{{- default .Chart.Name $ppx.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wrapper-prometheus-process-exporter.fullname" -}}
{{- $ppx := index .Values "prometheus-process-exporter" -}}
{{- if $ppx.fullnameOverride -}}
{{- $ppx.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name $ppx.nameOverride -}}
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
{{- define "wrapper-prometheus-process-exporter.serviceAccountName" -}}
{{- $ppx := index .Values "prometheus-process-exporter" -}}
{{- if $ppx.serviceAccount.create -}}
    {{ default (include "wrapper-prometheus-process-exporter.fullname" .) $ppx.serviceAccount.name }}
{{- else -}}
    {{ default "default" $ppx.serviceAccount.name }}
{{- end -}}
{{- end -}}

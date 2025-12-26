{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-registry.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "docker-registry.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "docker-registry.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "docker-registry.selectorLabels" -}}
app.kubernetes.io/name: {{ include "docker-registry.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "docker-registry.registryname" -}}
{{- regexReplaceAll "[^a-zA-Z0-9]+" . "-" -}}
{{- end -}}

{{- define "docker-registry.registryvalues" -}}
{{- $values         := (.Values | default dict) -}}
{{- $registryName   := .registry -}}
{{- $defaultValues  := (index $values "default" | default dict) -}}
{{- $registryValues := (index (index $values "proxies" | default dict) $registryName | default dict) -}}

{{- deepCopy $defaultValues | mergeOverwrite $registryValues | fromYaml -}}
{{- end -}}

{{- define "docker-registry.storage-type" -}}
{{- $type := . -}}
{{- if eq $type "azure" -}}
azure
{{- else if eq $type "gcs" -}}
gcs
{{- else if eq $type "s3" -}}
s3
{{- else if eq $type "inmemory" -}}
inmemory
{{- else -}}
filesystem
{{- end -}}
{{- end -}}

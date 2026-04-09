{{- define "coredns-wrapper.name" -}}
{{- default .Chart.Name .Values.coredns.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "coredns-wrapper.fullname" -}}
{{- if .Values.coredns.fullnameOverride -}}
{{- .Values.coredns.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.coredns.nameOverride -}}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "coredns-wrapper.k8sapplabel" -}}
{{- default .Chart.Name .Values.coredns.k8sAppLabelOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "coredns-wrapper.serviceAccountName" -}}
{{- if .Values.coredns.serviceAccount.create -}}
    {{ default (include "coredns-wrapper.fullname" .) .Values.coredns.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.coredns.serviceAccount.name }}
{{- end -}}
{{- end -}}

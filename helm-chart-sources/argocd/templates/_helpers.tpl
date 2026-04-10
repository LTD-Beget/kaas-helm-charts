{{- define "argo-cd-wrapper.name" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- default .Chart.Name $argocd.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "argo-cd-wrapper.fullname" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- if $argocd.fullnameOverride -}}
{{- $argocd.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name $argocd.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "argo-cd-wrapper.namespace" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- default .Release.Namespace $argocd.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "argo-cd-wrapper.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ include "argo-cd-wrapper.name" .context }}-{{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{- define "argo-cd-wrapper.applicationSet.fullname" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- printf "%s-%s" (include "argo-cd-wrapper.fullname" .) $argocd.applicationSet.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "argo-cd-wrapper.controller.fullname" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- printf "%s-%s" (include "argo-cd-wrapper.fullname" .) $argocd.controller.name | trunc 52 | trimSuffix "-" -}}
{{- end -}}

{{- define "argo-cd-wrapper.redis.fullname" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- $redisHa := (index $argocd "redis-ha") -}}
{{- $redisHaContext := dict "Chart" (dict "Name" "redis-ha") "Release" .Release "Values" $redisHa -}}
{{- if $redisHa.enabled -}}
    {{- if $redisHa.haproxy.enabled -}}
        {{- printf "%s-haproxy" (include "redis-ha.fullname" $redisHaContext) | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
{{- else -}}
{{- printf "%s-%s" (include "argo-cd-wrapper.fullname" .) $argocd.redis.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "argo-cd-wrapper.repoServer.fullname" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- printf "%s-%s" (include "argo-cd-wrapper.fullname" .) $argocd.repoServer.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "argo-cd-wrapper.server.fullname" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- printf "%s-%s" (include "argo-cd-wrapper.fullname" .) $argocd.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "argo-cd-wrapper.applicationSet.serviceAccountName" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- if $argocd.applicationSet.serviceAccount.create -}}
    {{ default (include "argo-cd-wrapper.applicationSet.fullname" .) $argocd.applicationSet.serviceAccount.name }}
{{- else -}}
    {{ default "default" $argocd.applicationSet.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "argo-cd-wrapper.controller.serviceAccountName" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- if $argocd.controller.serviceAccount.create -}}
    {{ default (include "argo-cd-wrapper.controller.fullname" .) $argocd.controller.serviceAccount.name }}
{{- else -}}
    {{ default "default" $argocd.controller.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "argo-cd-wrapper.redis.serviceAccountName" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- if $argocd.redis.serviceAccount.create -}}
    {{ default (include "argo-cd-wrapper.redis.fullname" .) $argocd.redis.serviceAccount.name }}
{{- else -}}
    {{ default "default" $argocd.redis.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "argo-cd-wrapper.repoServer.serviceAccountName" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- if $argocd.repoServer.serviceAccount.create -}}
    {{ default (include "argo-cd-wrapper.repoServer.fullname" .) $argocd.repoServer.serviceAccount.name }}
{{- else -}}
    {{ default "default" $argocd.repoServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "argo-cd-wrapper.server.serviceAccountName" -}}
{{- $argocd := index .Values "argo-cd" -}}
{{- if $argocd.server.serviceAccount.create -}}
    {{ default (include "argo-cd-wrapper.server.fullname" .) $argocd.server.serviceAccount.name }}
{{- else -}}
    {{ default "default" $argocd.server.serviceAccount.name }}
{{- end -}}
{{- end -}}

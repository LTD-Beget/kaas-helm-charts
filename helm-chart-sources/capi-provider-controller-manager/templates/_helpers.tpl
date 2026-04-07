{{- define "providerControllerManager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "providerControllerManager.labels" -}}

helm.sh/chart: {{ include "providerControllerManager.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "providerControllerManager.applicationSelectorLabels" -}}
{{- $applicationName := index $ 0 }}
{{- $globalValue     := index $ 1 }}
app.kubernetes.io/name: {{ $applicationName }}
app.kubernetes.io/instance: {{ $globalValue.Release.Name }}
{{- end }}

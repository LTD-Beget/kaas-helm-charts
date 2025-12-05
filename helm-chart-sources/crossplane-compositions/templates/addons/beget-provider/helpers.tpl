{{- define "addons.begetcmprovider" }}
name: BegetCmProvider
debug: false
path: .
repoURL: https://gitlab.beget.ru/cloud/k8s/charts/capi-provider-beget-controller-manager.git
{{- $addonValue := dig "composite" "addons" "begetcmprovider" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}

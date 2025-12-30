{{- define "addons.dockerregistrycache" }}
name: DockerRegistryCache
debug: false
path: helm-chart-sources/docker-registry-cache
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "dockerregistrycache" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}

{{- define "addons.etcdbackups" }}
name: EtcdBackup
debug: false
path: helm-chart-sources/etcd-backup-snapshot
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "etcdbackups" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}

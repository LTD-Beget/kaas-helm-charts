{{- define "addons.etcdbackups" }}
name: EtcdBackup
debug: false
path: helm-chart-sources/etcd-backup-snapshot
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD
{{- end }}

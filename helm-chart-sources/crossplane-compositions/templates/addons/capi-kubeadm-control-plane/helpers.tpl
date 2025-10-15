{{- define "addons.capikubeadmcontrolplane" }}
name: CapiKubeadmControlPlane
debug: false
path: helm-chart-sources/capi-kubeadm-control-plane
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD
{{- end }}

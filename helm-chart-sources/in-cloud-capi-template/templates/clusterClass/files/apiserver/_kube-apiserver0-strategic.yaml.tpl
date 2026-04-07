{{- define "in-cloud-capi-template.files.apiserver.kubeApiserver0Strategic.yaml" -}}
- path: /etc/kubernetes/patches/kube-apiserver0+strategic.yaml
  owner: "root:root"
  permissions: "0644"
  content: |
    apiVersion: v1
    kind: Pod
    spec:
      dnsPolicy: ClusterFirstWithHostNet
{{- end }}
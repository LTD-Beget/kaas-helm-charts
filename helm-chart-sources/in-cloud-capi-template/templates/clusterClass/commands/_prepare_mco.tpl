{{- define "in-cloud-capi-template.mcoPreKubeadmCommands" -}}
- ln -s /etc/kubernetes/kubelet.conf  /etc/kubernetes/kubeconfig
- ln -s /etc/kubernetes/kubelet.conf /var/lib/kubelet/kubeconfig
{{- end }}

{{- define "in-cloud-capi-template.files.kubelet.service" -}}
- path: /usr/lib/systemd/system/kubelet.service
  owner: root:root
  permissions: '0644'
  content: |
    [Unit]
    Description=kubelet: The Kubernetes Node Agent
    Documentation=https://kubernetes.io/docs/
    Wants=network-online.target containerd.service kubelet-install.service
    After=network-online.target containerd.service kubelet-install.service
    Wants=containerd.service
    
    [Service]
    ExecStart=/usr/local/bin/kubelet
    Restart=always
    StartLimitInterval=0
    RestartSec=10
    
    [Install]
    WantedBy=multi-user.target
{{- end }}

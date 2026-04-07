{{- define "in-cloud-capi-template.files.containerd.service" -}}
- path: /usr/lib/systemd/system/containerd.service
  owner: root:root
  permissions: '0644'
  content: |
    [Unit]
    Description=containerd container runtime
    Documentation=https://containerd.io
    After=network.target local-fs.target containerd-install.service runc-install.service
    Wants=containerd-install.service runc-install.service
    
    [Service]
    ExecStartPre=-/sbin/modprobe overlay
    ExecStart=/usr/local/bin/containerd
    
    Type=notify
    Delegate=yes
    KillMode=process
    Restart=always
    RestartSec=5
    LimitNPROC=infinity
    LimitCORE=infinity
    LimitNOFILE=infinity
    TasksMax=infinity
    OOMScoreAdjust=-999
    
    [Install]
    WantedBy=multi-user.target
{{- end }}

{{- define "in-cloud-capi-template.files.containerd.configCustom.toml" -}}
- path: /etc/containerd/conf.d/in-cloud.toml
  owner: root:root
  permissions: '0644'
  content: |
    version = 2       
    [plugins]
      [plugins."io.containerd.grpc.v1.cri"]
        sandbox_image = "registry.k8s.io/pause:{{`{{ .pauseVersion }}`}}"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
        runtime_type = "io.containerd.runc.v2"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        SystemdCgroup = true
      [plugins."io.containerd.grpc.v1.cri".registry]
        config_path = "/etc/containerd/certs.d/"
{{- end }}

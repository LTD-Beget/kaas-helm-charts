{{/*
Bundle: generates all three download cloud-init files for a component
(download-script.sh, download.env, download.service) in one call.

Usage:
  include "in-cloud-capi-template.files.common.downloadBundle"
    (dict "name"        "containerd"
          "bin"         $components.containerd.bin
          "versionExpr" "{{ .containerdVersion }}"
          "body"        "in-cloud-capi-template.files.containerd.downloadScript.sh"
          "root"        .root)
*/}}
{{- define "in-cloud-capi-template.files.common.downloadBundle" -}}
{{ include "in-cloud-capi-template.files.common.downloadScript.sh"
    (dict "bin"  .bin
          "path" (printf "/etc/default/%s/download-script.sh" .name)
          "body" .body
          "root" .root) }}
{{ include "in-cloud-capi-template.files.common.download.env"
    (dict "name"        .name
          "versionExpr" .versionExpr
          "repository"  .bin.repository) }}
{{ include "in-cloud-capi-template.files.common.download.service"
    (dict "name" .name) }}
{{- end }}

{{/*
Generic template for a component download-script.sh cloud-init file.
Generates the env header and includes the component-specific body.
*/}}
{{- define "in-cloud-capi-template.files.common.downloadScript.sh" -}}
- path: {{ .path }}
  owner: root:root
  permissions: '0755'
  content: |
    #!/bin/bash
    set -Eeuo pipefail

    COMPONENT_VERSION="${COMPONENT_VERSION:-{{ .bin.version }}}"
    REPOSITORY="${REPOSITORY:-{{ .bin.repository }}}"
    PATH_BIN="${REPOSITORY}/{{ .bin.pathBin }}"
    PATH_SHA256="${REPOSITORY}/{{ .bin.pathSha256 }}"
    INSTALL_PATH="{{ .bin.installPath }}"

{{ include .body .root }}
{{- end }}

{{/*
Generic template for a component download.env cloud-init file.
The systemd EnvironmentFile that overrides COMPONENT_VERSION at boot.
*/}}
{{- define "in-cloud-capi-template.files.common.download.env" -}}
- path: /etc/default/{{ .name }}/download.env
  owner: root:root
  permissions: '0644'
  content: |
    COMPONENT_VERSION="{{ .versionExpr }}"
    REPOSITORY="{{ .repository }}"
{{- end }}

{{/*
Generic template for a component install systemd service.
*/}}
{{- define "in-cloud-capi-template.files.common.download.service" -}}
- path: /usr/lib/systemd/system/{{ .name }}-install.service
  owner: root:root
  permissions: '0644'
  content: |
    [Unit]
    Description=Install and update in-cloud component {{ .name }}
    After=network.target
    Wants=network-online.target
    
    [Service]
    Type=oneshot
    EnvironmentFile=-/etc/default/{{ .name }}/download.env
    ExecStart=/bin/bash -c "/etc/default/{{ .name }}/download-script.sh"
    RemainAfterExit=yes
    
    [Install]
    WantedBy=multi-user.target
{{- end }}

{{/*
Generic OpenSSL CNF cloud-init file for a kube component TLS certificate.
Usage: include "...common.tlsCnf"
  (dict "name" "controller-manager"
        "cn"   "system:kube-controller-manager-server"
        "withFQDN" false)
*/}}
{{- define "in-cloud-capi-template.files.common.tlsCnf" -}}
- path: /etc/kubernetes/pki/{{ .name }}-server.cnf
  owner: root:root
  permissions: '0644'
  content: |
    [req]
    default_bits = 2048
    prompt = no
    default_md = sha256
    distinguished_name = dn
    req_extensions = req_ext

    [dn]
    CN = {{ .cn }}

    [req_ext]
    subjectAltName = @alt_names
    keyUsage = critical, keyEncipherment, dataEncipherment
    extendedKeyUsage = serverAuth

    [alt_names]
    DNS.1 = {{ `{{ .builtin.cluster.name }}` }}-{{ .name }}
    DNS.2 = {{ `{{ .builtin.cluster.name }}` }}-{{ .name }}.kube-system
    DNS.3 = {{ `{{ .builtin.cluster.name }}` }}-{{ .name }}.kube-system.svc
    {{- if .withFQDN }}
    DNS.4 = {{ `{{ .builtin.cluster.name }}` }}-{{ .name }}.kube-system.svc.cluster.local
    {{- end }}
    IP.1 = 127.0.0.1
{{- end }}

{{/*
Generic OpenSSL CNF cloud-init file for a kube component client TLS certificate.
Usage:
include "in-cloud-capi-template.files.common.clientTlsCnf"
  (dict "name" "rbac-proxy"
        "cn"   "system:rbac-proxy")
*/}}
{{- define "in-cloud-capi-template.files.common.clientTlsCnf" -}}
- path: /etc/kubernetes/pki/{{ .name }}-client.cnf
  owner: root:root
  permissions: '0644'
  content: |
    [req]
    default_bits = 2048
    prompt = no
    default_md = sha256
    distinguished_name = dn
    req_extensions = req_ext

    [dn]
    CN = {{ .cn }}

    [req_ext]
    keyUsage = critical, digitalSignature, keyEncipherment
    extendedKeyUsage = clientAuth
{{- end }}

{{/*
Generic TLS certificate cloud-init file (contentFrom secret).
Usage: include "...common.tlsCrt" (dict "name" "controller-manager")
*/}}
{{- define "in-cloud-capi-template.files.common.tlsCrt" -}}
- path: /etc/kubernetes/pki/{{ .name }}-server.crt
  owner: root:root
  permissions: '0644'
  contentFrom:
    secret:
      name: "{{`{{ .builtin.cluster.name }}`}}-{{ .name }}"
      key: tls.crt
{{- end }}

{{/*
Generic TLS private key cloud-init file (contentFrom secret).
Usage: include "...common.tlsKey" (dict "name" "controller-manager")
*/}}
{{- define "in-cloud-capi-template.files.common.tlsKey" -}}
- path: /etc/kubernetes/pki/{{ .name }}-server.key
  owner: root:root
  permissions: '0600'
  contentFrom:
    secret:
      name: "{{`{{ .builtin.cluster.name }}`}}-{{ .name }}"
      key: tls.key
{{- end }}

{{- define "in-cloud-capi-template.commands.common.prepare" -}}
- apt install -y wget tree net-tools conntrack socat jq
- export KUBEADM_CONFIG_FILE=$(find /var/run/kubeadm/*.yaml)
- export ADVERTISE_ADDRESS=$(ip -j addr show eth1 | jq -r '.[].addr_info[] | select(.family == "inet") | .local')
- envsubst < ${KUBEADM_CONFIG_FILE} > ${KUBEADM_CONFIG_FILE}.tmp && mv ${KUBEADM_CONFIG_FILE}.tmp ${KUBEADM_CONFIG_FILE}
- modprobe overlay
- modprobe br_netfilter
- sysctl --system
- systemctl restart containerd-install.service
- systemctl daemon-reload
- systemctl restart containerd
- systemctl daemon-reexec
{{- end }}

{{- define "in-cloud-capi-template.commandsCp.all.aggregate" -}}
{{- include "in-cloud-capi-template.commands.common.prepare" . }}
{{- if not .Values.capi.externalSecrets.controllerManager.enabled }}
{{- .Values.capi.externalSecrets.controllerManager.targetComands          | toYaml | nindent 0 }}
{{- end }}
{{- if not .Values.capi.externalSecrets.scheduler.enabled }}
{{- .Values.capi.externalSecrets.scheduler.targetComands                  | toYaml | nindent 0 }}
{{- end }}
{{- .Values.capi.k8s.controlPlane.components.etcd.bin.targetComands       | toYaml | nindent 0 }}
{{- .Values.capi.k8s.controlPlane.components.runc.bin.targetComands       | toYaml | nindent 0 }}
{{- .Values.capi.k8s.controlPlane.components.crictl.bin.targetComands     | toYaml | nindent 0 }}
{{- .Values.capi.k8s.controlPlane.components.kubectl.bin.targetComands    | toYaml | nindent 0 }}
{{- .Values.capi.k8s.controlPlane.components.kubeadm.bin.targetComands    | toYaml | nindent 0 }}
{{- .Values.capi.k8s.controlPlane.components.kubelet.bin.targetComands    | toYaml | nindent 0 }}
{{- .Values.capi.k8s.controlPlane.components.containerd.bin.targetComands | toYaml | nindent 0 }}
{{- .Values.capi.k8s.controlPlane.components.helm.bin.targetComands       | toYaml | nindent 0 }}
- systemctl restart systemd-resolved
{{- end }}

{{- define "in-cloud-capi-template.commandsDp.all.aggregate" -}}
{{- include "in-cloud-capi-template.commands.common.prepare" . }}
{{- .Values.capi.k8s.dataPlane.components.runc.bin.targetComands       | toYaml | nindent 0 }}
{{- .Values.capi.k8s.dataPlane.components.crictl.bin.targetComands     | toYaml | nindent 0 }}
{{- .Values.capi.k8s.dataPlane.components.kubectl.bin.targetComands    | toYaml | nindent 0 }}
{{- .Values.capi.k8s.dataPlane.components.kubeadm.bin.targetComands    | toYaml | nindent 0 }}
{{- .Values.capi.k8s.dataPlane.components.kubelet.bin.targetComands    | toYaml | nindent 0 }}
{{- .Values.capi.k8s.dataPlane.components.containerd.bin.targetComands | toYaml | nindent 0 }}
{{- .Values.capi.k8s.controlPlane.components.helm.bin.targetComands   | toYaml | nindent 0 }}
- systemctl restart systemd-resolved
{{- end }}

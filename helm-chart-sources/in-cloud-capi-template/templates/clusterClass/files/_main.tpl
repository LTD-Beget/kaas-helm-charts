{{- define "in-cloud-capi-template.files.all.aggregate.controlPlane" -}}
{{- $ctx := (dict "plane" "controlPlane" "root" $) -}}
{{- $components := $.Values.capi.k8s.controlPlane.components -}}
    {{- include "in-cloud-capi-template.files.postKubeadmCommands.aggregate.controlPlane"   $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.bashrc.aggregate"                             $ | nindent 0 }}
    {{- if $components.containerd.enabled }}
    {{- include "in-cloud-capi-template.files.containerd.aggregate"                       $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.runc.enabled }}
    {{- include "in-cloud-capi-template.files.runc.aggregate"                             $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.crictl.enabled }}
    {{- include "in-cloud-capi-template.files.crictl.aggregate"                           $ctx | nindent 0 }}
    {{- end }}
    {{- include "in-cloud-capi-template.files.etcd.aggregate"                             $ctx | nindent 0 }}
    {{- if $components.helm.enabled }}
    {{- include "in-cloud-capi-template.files.helm.aggregate"                             $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.kubeadm.enabled }}
    {{- include "in-cloud-capi-template.files.kubeadm.aggregate"                          $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.kubectl.enabled }}
    {{- include "in-cloud-capi-template.files.kubectl.aggregate"                          $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.kubelet.enabled }}
    {{- include "in-cloud-capi-template.files.kubelet.aggregate"                          $ctx | nindent 0 }}
    {{- end }}
    {{- include "in-cloud-capi-template.files.security.aggregate"                           $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.sysctls.aggregate"                            $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.systemd.aggregate"                            $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.cni.99-loopback.conf"                        $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.audit.aggregate.controlPlane"                $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.controllerManager.aggregate.controlPlane"    $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.scheduler.aggregate.controlPlane"            $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.apiserver.aggregate.controlPlane"            $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.rbacProxy.aggregate.controlPlane"            $ | nindent 0 }}
{{- end -}}

{{- define "in-cloud-capi-template.files.all.aggregate.dataPlane" -}}
{{- $ctx := (dict "plane" "dataPlane" "root" $) -}}
{{- $components := $.Values.capi.k8s.dataPlane.components -}}
    {{- include "in-cloud-capi-template.files.postKubeadmCommands.aggregate.dataPlane"     $ | nindent 0 }}
    {{- if $components.containerd.enabled }}
    {{- include "in-cloud-capi-template.files.containerd.aggregate"                      $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.runc.enabled }}
    {{- include "in-cloud-capi-template.files.runc.aggregate"                            $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.crictl.enabled }}
    {{- include "in-cloud-capi-template.files.crictl.aggregate"                          $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.kubeadm.enabled }}
    {{- include "in-cloud-capi-template.files.kubeadm.aggregate"                         $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.kubectl.enabled }}
    {{- include "in-cloud-capi-template.files.kubectl.aggregate"                         $ctx | nindent 0 }}
    {{- end }}
    {{- if $components.kubelet.enabled }}
    {{- include "in-cloud-capi-template.files.kubelet.aggregate"                         $ctx | nindent 0 }}
    {{- include "in-cloud-capi-template.files.kubelet.service.args"                       $ | nindent 0 }}
    {{- end }}
    {{- include "in-cloud-capi-template.files.security.aggregate"                          $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.sysctls.aggregate"                           $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.systemd.aggregate"                           $ | nindent 0 }}
    {{- include "in-cloud-capi-template.files.apiserver.caOidc.crt.dataPlane"                        $ | nindent 0 }}
{{- end -}}

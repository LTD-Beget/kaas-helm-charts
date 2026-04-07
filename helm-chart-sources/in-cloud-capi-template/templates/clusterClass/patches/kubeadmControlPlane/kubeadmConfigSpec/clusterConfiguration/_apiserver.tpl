{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.apiserver" -}}
{{ include "in-cloud-capi-template.patches.common.clusterConfigurationComponent"
    (dict "component"      "apiServer"
          "certSANsFields" (list "certSANs")
          "root" $) }}
{{- end -}}

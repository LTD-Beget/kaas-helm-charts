{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.scheduler" -}}
{{ include "in-cloud-capi-template.patches.common.clusterConfigurationComponent" (dict "component" "scheduler" "root" $) }}
{{- end -}}

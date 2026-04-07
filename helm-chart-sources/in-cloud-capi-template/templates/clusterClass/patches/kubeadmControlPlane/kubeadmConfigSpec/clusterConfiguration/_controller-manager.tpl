{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.controllerManager" -}}
{{ include "in-cloud-capi-template.patches.common.clusterConfigurationComponent" (dict "component" "controllerManager" "root" $) }}
{{- end -}}

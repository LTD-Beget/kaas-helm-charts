{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.initConfiguration.patches" -}}
{{ include "in-cloud-capi-template.patches.common.configurationPatches" (dict "configuration" "initConfiguration") }}
{{- end -}}

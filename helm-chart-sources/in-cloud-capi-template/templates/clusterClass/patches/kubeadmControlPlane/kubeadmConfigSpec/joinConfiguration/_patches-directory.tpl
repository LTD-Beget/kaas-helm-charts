{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.joinConfiguration.patches" -}}
{{ include "in-cloud-capi-template.patches.common.configurationPatches" (dict "configuration" "joinConfiguration") }}
{{- end -}}

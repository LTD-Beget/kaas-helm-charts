{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.joinConfiguration.nodeRegistration" -}}
{{ include "in-cloud-capi-template.patches.common.nodeRegistration"
    (dict "configuration"        "joinConfiguration"
          "advertiseAddressPath" "/spec/template/spec/kubeadmConfigSpec/joinConfiguration/controlPlane/localAPIEndpoint/advertiseAddress"
          "root" $) }}
{{- end -}}

{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.initConfiguration.nodeRegistration" -}}
{{ include "in-cloud-capi-template.patches.common.nodeRegistration"
    (dict "configuration"        "initConfiguration"
          "advertiseAddressPath" "/spec/template/spec/kubeadmConfigSpec/initConfiguration/localAPIEndpoint/advertiseAddress"
          "root" $) }}
{{- end -}}

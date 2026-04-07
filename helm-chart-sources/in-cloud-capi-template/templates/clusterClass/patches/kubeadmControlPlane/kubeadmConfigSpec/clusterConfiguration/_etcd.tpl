{{- define "in-cloud-capi-template.patches.kubeadmControlPlane.kubeadmConfigSpec.clusterConfiguration.etcd" -}}
{{ include "in-cloud-capi-template.patches.common.clusterConfigurationComponent"
    (dict "component"        "etcd"
          "pathPrefix"       "etcd/local"
          "certSANsFields"  (list "serverCertSANs" "peerCertSANs")
          "withExtraVolumes" false
          "root" $) }}
{{- end -}}

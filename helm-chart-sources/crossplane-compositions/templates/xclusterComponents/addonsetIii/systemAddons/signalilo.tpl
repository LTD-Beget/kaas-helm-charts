{{- define "xclusterComponents.addonsetIii.signalilo" -}}
  {{- printf `
signalilo:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsSignalilo
  namespace: beget-signalilo
  version: v1alpha1
  releaseName: signalilo
  dependsOn:
    - vmOperator
  values:
    signalilo:
      config:
        uuid: 9ec06d59-aa0c-4434-b5e2-1aeaf93cd925
        icinga_hostname: 192.168.88.204
        icinga_url: http://192.168.88.204:5665
        icinga_username: admin
        icinga_password: "Hash#Web44GoInterface"
        alertmanager_port: 8888
  ` }}
{{- end -}}

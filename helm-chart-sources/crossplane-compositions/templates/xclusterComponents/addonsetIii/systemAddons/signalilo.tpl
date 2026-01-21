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
      fullnameOverride: "signalilo"
      config:
        uuid: da4c0b1d-da4c-4f3b-9e5d-c23f5fcd751a
        icinga_hostname: "{{ $clusterName }}"
        icinga_url: http://192.168.88.204:5665
        icinga_username: admin
        icinga_password: "Hash#Web44GoInterface"
        alertmanager_port: 80
        alertmanager_bearer_token: HrVSzDOrZthErVJwxddMJHefHYkvr/XWVc1XGcazh1I=

      extraEnvVars:
        - name: SIGNALILO_LOG_LEVEL
          value: "2"
        # - name: SIGNALILO_ICINGA_INSECURE_TLS
        #   value: "false"

      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
  ` }}
{{- end -}}

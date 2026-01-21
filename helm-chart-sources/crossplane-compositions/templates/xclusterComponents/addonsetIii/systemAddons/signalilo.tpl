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
        icinga_url: https://192.168.88.204:25665
        icinga_username: root
        icinga_password: "13283597db083426"
        alertmanager_port: 8888
        alertmanager_bearer_token: HrVSzDOrZthErVJwxddMJHefHYkvr/XWVc1XGcazh1I=

      extraEnvVars:
        - name: SIGNALILO_LOG_LEVEL
          value: "2"
        - name: SIGNALILO_ICINGA_INSECURE_TLS
          value: "true"
        - name: SIGNALILO_ICINGA_DEBUG
          value: "true"

      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
  ` }}
{{- end -}}

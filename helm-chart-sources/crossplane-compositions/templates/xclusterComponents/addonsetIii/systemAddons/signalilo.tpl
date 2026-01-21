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
      extraEnvVars:
        - name: SIGNALILO_UUID
          value: da4c0b1d-da4c-4f3b-9e5d-c23f5fcd751a
        - name: SIGNALILO_ICINGA_HOSTNAME
          value: "{{ $clusterName }}"
        - name: SIGNALILO_ICINGA_URL
          value:  http://192.168.88.204:5665
        - name: SIGNALILO_ALERTMANAGER_PORT
          value: 80
        - name: SIGNALILO_LOG_LEVEL
          value: "2"
        # - name: SIGNALILO_ALERTMANAGER_BEARER_TOKEN
        #   valueFrom:
        #     secretKeyRef:
        #       name: signalilo-secrets
        #       key: "alertmanager_bearer_token"
        - name: SIGNALILO_ICINGA_USERNAME
          valueFrom:
            secretKeyRef:
              name: signalilo-secrets
              key: "icinga_username"
        - name: SIGNALILO_ICINGA_PASSWORD
          valueFrom:
            secretKeyRef:
              name: signalilo-secrets
              key: "icinga_password"

    secrets:
      icinga_username: admin
      icinga_password: "Hash#Web44GoInterface"
      alertmanager_bearer_token: ""
  ` }}
{{- end -}}

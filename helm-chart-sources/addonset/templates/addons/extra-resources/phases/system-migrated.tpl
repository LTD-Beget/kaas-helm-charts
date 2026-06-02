{{- define "extra-resources.phase.rules.system-migrated" -}}
- name: system-migrated
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.systemEnabled
      operator: Equal
      value: "true"
      keep: false
    - source:
        apiVersion: v1
        kind: Secret
        name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
      operator: Exists
    - source:
        apiVersion: clusterclaim.in-cloud.io/v1alpha1
        kind: ClusterClaim
        name: {{ .Values.clusterClaim }}
        namespace: {{ .Values.companyPrefix }}-system
      keep: false
      jsonPath: $.metadata.uid
      operator: Exists
  selector:
    name: system-migrated
    priority: 43
    matchLabels:
      addons.in-cloud.io/values: system-migrated
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}

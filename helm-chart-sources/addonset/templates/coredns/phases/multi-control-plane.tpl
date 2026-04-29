{{- define "coredns.phase.multi-control-plane" }}
- name: multi-control-plane
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.environment
      operator: Equal
      value: "infra"
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.controlPlaneAvailableReplicas
      operator: GreaterThan
      value: 1
      keep: false
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.controlPlaneDesiredReplicas
      operator: GreaterThan
      value: 1
      keep: false
  selector:
    name: multi-control-plane
    priority: 30
    matchLabels:
      addons.in-cloud.io/values: multi-control-plane
      addons.in-cloud.io/addon: coredns
{{- end }}
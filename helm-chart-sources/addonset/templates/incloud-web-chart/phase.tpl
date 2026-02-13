{{- define "incloud-web-chart.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: incloud-web-chart{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: infra
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{ end }}
            namespace: beget-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
      selector:
        name: infra
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: incloud-web-chart
    - name: vm-operator
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: vm-operator{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: vm-operator
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: vm-operator
          addons.in-cloud.io/addon: incloud-web-chart
    - name: istio-base
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: istio-base{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: istio-base
        priority: 40
        matchLabels:
          addons.in-cloud.io/values: istio-base
          addons.in-cloud.io/addon: incloud-web-chart
    - name: system
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{ end }}
            namespace: beget-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "True"
      selector:
        name: system
        priority: 40
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: incloud-web-chart
{{- end }}


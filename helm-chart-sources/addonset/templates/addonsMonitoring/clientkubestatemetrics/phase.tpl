{{- define "clientkubestatemetrics.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: client-kube-state-metrics
spec:
  rules:
    - name: cert-manager
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.phaseValuesSelector[?(@.name=='initialized-2')]
          operator: Exists
      selector:
        name: cert-manager
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: cert-manager
          addons.in-cloud.io/addon: client-kube-state-metrics
    - name: vm-operator
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: vm-operator
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: vm-operator
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: vm-operator
          addons.in-cloud.io/addon: client-kube-state-metrics
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
        priority: 50
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: client-kube-state-metrics
{{- end }}

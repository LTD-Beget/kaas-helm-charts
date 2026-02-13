{{- define "coredns.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: coredns{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: initialized
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: coredns{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: initialized
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: initialized
          addons.in-cloud.io/addon: coredns
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
        priority: 15
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: coredns
    - name: cert-manager
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: cert-manager
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: cert-manager
          addons.in-cloud.io/addon: coredns
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
          addons.in-cloud.io/addon: coredns
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
          addons.in-cloud.io/addon: coredns
    - name: multi-control-plane
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{ end }}
            namespace: beget-system
          jsonPath: $.data.controlPlaneReplicas
          operator: GreaterThan
          value: 1
      selector:
        name: multi-control-plane
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: multi-control-plane
          addons.in-cloud.io/addon: coredns
{{- end }}

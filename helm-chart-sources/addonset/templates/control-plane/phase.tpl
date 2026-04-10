{{- define "control-plane.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: client-cp-control-plane
spec:
  rules:
    - name: vm-operator
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: vm-operator{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: vm-operator{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
      selector:
        name: vm-operator
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: "vm-operator"
          addons.in-cloud.io/addon: client-cp-control-plane
    - name: cilium
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cilium{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cilium{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
      selector:
        name: cilium
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: cilium
          addons.in-cloud.io/addon: client-cp-control-plane
    - name: disable
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: client-cp-control-plane
          jsonPath: $.spec.variables.controlPlaneReplicas
          operator: Equal
          value: 0
          keep: false
      selector:
        name: disable
        priority: 98
        matchLabels:
          addons.in-cloud.io/values: "disable"
          addons.in-cloud.io/addon: client-cp-control-plane
{{- end }}

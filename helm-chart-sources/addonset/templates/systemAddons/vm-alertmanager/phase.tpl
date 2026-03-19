{{- define "vmalertmanager.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: vm-alertmanager
spec:
  rules:
    - name: cert-manager
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: trust-manager
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: cert-manager
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: cert-manager
          addons.in-cloud.io/addon: vm-alertmanager
    - name: signalilo
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: signalilo
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: signalilo
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
      selector:
        name: signalilo
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: signalilo
          addons.in-cloud.io/addon: vm-alertmanager
{{- end }}

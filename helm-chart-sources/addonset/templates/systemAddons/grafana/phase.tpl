{{- define "grafana.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: grafana{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: cert-manager
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
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
            name: trust-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: cert-manager
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: "cert-manager"
          addons.in-cloud.io/addon: grafana
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
          addons.in-cloud.io/addon: grafana
    - name: istio-gw
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: istio-gw{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: istio-gw
        priority: 40
        matchLabels:
          addons.in-cloud.io/values: istio-gw
          addons.in-cloud.io/addon: grafana
{{- end }}

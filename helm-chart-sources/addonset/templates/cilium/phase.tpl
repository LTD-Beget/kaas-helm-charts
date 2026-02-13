{{- define "cilium.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: cilium{{ if eq .Values.environment "client" }}-client{{ end }}
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
      selector:
        name: cert-manager
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: "cert-manager"
          addons.in-cloud.io/addon: cilium  
{{- end }}

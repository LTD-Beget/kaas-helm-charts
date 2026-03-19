{{- define "vm-agent-additional-rbac.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: helm-inserter-vm-agent-additional-rbac{{ if eq .Values.environment "client" }}-client{{ end }}
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
        priority: 15
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: helm-inserter-vm-agent-additional-rbac
    {{- end }}

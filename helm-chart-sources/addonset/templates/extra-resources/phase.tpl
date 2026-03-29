{{- define "extra-resources.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: extra-resources{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: infra
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: beget-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "false"
          keep: false
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: beget-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
      selector:
        name: infra
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: extra-resources
    - name: client
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: beget-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "false"
          keep: false
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: beget-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
      selector:
        name: client
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: client
          addons.in-cloud.io/addon: extra-resources
    - name: system
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: beget-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "true"
          keep: false
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: beget-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
      selector:
        name: system
        priority: 40
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: extra-resources
    - name: system-issuer
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: beget-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "true"
          keep: false
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: beget-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
        - source:
            apiVersion: clusterclaim.in-cloud.io/v1alpha1
            kind: ClusterClaim
            name: {{ .Values.clusterName }}
            namespace: beget-system
          keep: false
          jsonPath: $.metadata.uid
          operator: Exists
      selector:
        name: system-issuer
        priority: 50
        matchLabels:
          addons.in-cloud.io/values: system-issuer
          addons.in-cloud.io/addon: extra-resources
{{- end }}

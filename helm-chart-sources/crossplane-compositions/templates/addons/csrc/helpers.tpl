{{- define "addons.csrc" }}
name: Csrc
debug: false
path: .
repoURL: "https://gitlab.beget.ru/cloud/k8s/charts/beget-certificate-signing-request-controller-chart"
{{- $addonValue := dig "composite" "addons" "csrc" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
default: |
  appSpec:
    applications:
      csrControllerManager:
        enabled: true
        # imagePullSecrets: []
        containers:
          manager:
            image:
              pullPolicy: Always
              tag: v1.0.2
            extraArgs:
              cluster-name: {{ "{{ .clusterName }}" }}
              cluster-namespace: {{ "{{ .argocdDestinationNamespace }}" }}
        volumes:
          secret-ccm-kubeconfig:
            volume:
              mode: secret
              secretName: {{ "{{ .clusterName }}-kubeconfig" }}
              items:
              - key: value
                path: kubeconfig
        service:
          enabled: true
{{- end }}

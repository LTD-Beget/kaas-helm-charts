{{- define "addons.csrc" }}
name: Csrc
debug: false
path: .
repoURL: "https://gitlab.beget.ru/cloud/k8s/charts/beget-certificate-signing-request-controller-chart"
targetRevision: HEAD
default: |
  appSpec:
    applications:
      csrControllerManager:
        enabled: true
        # imagePullSecrets: []
        containers:
          manager:
            extraArgs:
              cluster-name: {{ "{{ .clusterName }}" }}
              cluster-namespace: {{ "{{ .argocdDestinationNamespace }}" }}
            # image:
            #   tag: rc1
            #   pullPolicy: Always
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

{{- define "addons.ccm" }}
name: Ccm
debug: false
path: .
repoURL: https://gitlab.beget.ru/cloud/k8s/charts/beget-cloud-controller-manager-chart.git
targetRevision: HEAD
default: |
  appSpec:
    applications:
      cloudControllerManager:
        enabled: true
        imagePullSecrets: []
        containers:
          manager:
            extraEnv:
              CLUSTER_NAME: {{ "{{ .clusterName }}" }}
              CLUSTER_NAMESPACE: {{ "{{ .argocdDestinationNamespace }}" }}
            # image:
            #   tag: latest
            #   pullPolicy: Always
            extraArgs:
              v: 3
        volumes:
          secret-ccm-kubeconfig:
            volume:
              mode: secret
              secretName: {{ "{{ .clusterName }}-kubeconfig" }}
              items:
              - key: value
                path: kubeconfig
{{- end }}

{{- define "xclusterComponents.addonsetIii.vaultSecrets" -}}
  {{- printf `
vaultSecrets:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVaultSecrets
  namespace: beget-vault
  version: v1alpha1
  dependsOn:
    - vault
  values:
    regcred:
      enabled: true
      items:
        - name: regcred
          namespace: beget-cm-provider
          vaultPath: secret/data/docker-registry 
          key: dockerconfigjson                 
          isBase64: true                       
    argocd:
      enabled: true
      repositories:
        - name: capi-provider
          namespace: beget-argocd
          url: https://gitlab.beget.ru/cloud/k8s/charts/capi-provider-beget-controller-manager.git
          auth:
            vaultPath: secret/data/argocd-creds
            usernameKey: username
            passwordKey: password
        - name: cross-functions
          namespace: beget-argocd
          url: https://gitlab.beget.ru/cloud/k8s/charts/crossplane-functions.git
          auth:
            vaultPath: secret/data/argocd-creds
            usernameKey: username
            passwordKey: password
        - name: cross-xcluster
          namespace: beget-argocd
          url: https://gitlab.beget.ru/cloud/k8s/charts/crossplane-xcluster.git
          auth:
            vaultPath: secret/data/argocd-creds
            usernameKey: username
            passwordKey: password
        - name: cluster-claim
          namespace: beget-argocd
          url: https://gitlab.beget.ru/cloud/k8s/charts/cluster.git
          auth:
            vaultPath: secret/data/argocd-creds
            usernameKey: username
            passwordKey: password
        - name: capi-clusterclass
          namespace: beget-argocd
          url: https://gitlab.beget.ru/cloud/k8s/charts/in-cloud-capi.git
          auth:
            vaultPath: secret/data/argocd-creds
            usernameKey: username
            passwordKey: password
  ` }}
{{- end -}}
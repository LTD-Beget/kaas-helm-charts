{{- define "xclusterComponents.addonsetIii.argocd" -}}
  {{- printf `
argocd:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsArgocd
  finalizerDisabled: false
  namespace: beget-argocd
  version: v1alpha1
  dependsOn:
    - istioGW
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
  {{ end }}
    argo-cd:
  {{ if and $systemEnabled $argocdReady }}
      controller:
        resources:
          limits:
            cpu: '16'
            ephemeral-storage: 10Gi
          requests:
            cpu: 5
            ephemeral-storage: 500Mi
            memory: 6Gi
      global:
        nodeSelector:
          node-role.kubernetes.io/argocd: ''
        tolerations:
          - effect: NoSchedule
            key: node-role.kubernetes.io/argocd
            operator: Exists
          - effect: NoSchedule
            key: node-role.kubernetes.io/control-plane
            operator: Exists
          - effect: NoSchedule
            key: node-role.kubernetes.io/master
            operator: Exists
      redis:
        resources:
          limits:
            cpu: 1
            memory: 1Gi
  {{ end }}
      crds:
        install: true
      configs:
        cm:
          {{ if $systemEnabled }}
          url: {{ printf "https://%%s/argocd" $systemIstioGwVip }}
          {{ else }}
          url: "https://localhost/argocd"
          {{ end }}
          oidc.config: |
            name: Dex
            issuer: {{ printf "https://%%s" $systemIstioGwVip }}
            clientID: argocd
            clientSecret: argo-cd-super-secret
            requestedScopes: ["openid","profile","email","groups"]
            insecureSkipVerify: true
          oidc.tls.insecure.skip.verify: "true"
        cmp:
          create: true
          plugins:
            helm-with-values:
              allowConcurrency: true
              lockRepo: false
              discover:
                find:
                  command:
                    - bash
                    - '-c'
                    - |
                      if [ -n "${ARGOCD_ENV_HELM_VALUES+set}" ] ; then
                        find . -name 'Chart.yaml' &&
                        find . -name 'values.yaml'
                      fi
              generate:
                command:
                  - bash
                  - '-c'
                  - |
                      #!/bin/bash
                      set -e

                      if [ -z "${ARGOCD_ENV_RELEASE_NAME}" ]; then
                          ARGOCD_ENV_RELEASE_NAME="${ARGOCD_APP_NAME#*_}"
                      fi

                      echo "${ARGOCD_ENV_HELM_VALUES}" | base64 -d > ./additionalValues.yaml

                      KUSTOMIZE_ENABLED=$(yq e '.argocdPlugins.kustomize // false' ./additionalValues.yaml)
                      VAULT_ENABLED=$(yq e '.argocdPlugins.vault // false' ./additionalValues.yaml)

                      if [ "$KUSTOMIZE_ENABLED" = "true" ]; then
                          helm template "${ARGOCD_ENV_RELEASE_NAME}" --include-crds -n "${ARGOCD_APP_NAMESPACE}" -f ./additionalValues.yaml . > ./patches/base.yaml

                          OUTPUT=$(kustomize build ./patches)
                      else
                          OUTPUT=$(helm template "${ARGOCD_ENV_RELEASE_NAME}" --include-crds -n "${ARGOCD_APP_NAMESPACE}" -f ./additionalValues.yaml .)
                      fi

                      if [ "$VAULT_ENABLED" = "true" ]; then
                          echo "$OUTPUT" | argocd-vault-plugin generate -s beget-argocd:avp-config -
                      else
                          echo "$OUTPUT"
                      fi
        secret:
          argocdServerAdminPassword: {{ $argsArgocdServerAdminPassword }}
          argocdServerAdminPasswordMtime: {{ $xRCreationTimestamp }}
      redisSecretInit:
        enabled: false
      repoServer:
        volumes:
          - configMap:
              name: argocd-cmp-cm
            name: cmp-plugin
        # dnsPolicy: "ClusterFirstWithHostNet"
        extraContainers:
          - name: helm-with-values
            command: [/var/run/argocd/argocd-cmp-server]
            image: "dmkolbin/argocd-with-utils:v2.14.10"
            securityContext:
              runAsNonRoot: true
              runAsUser: 999
            volumeMounts:
              - mountPath: /var/run/argocd
                name: var-files
              - mountPath: /home/argocd/cmp-server/plugins
                name: plugins
              - mountPath: /home/argocd/cmp-server/config/plugin.yaml
                subPath: helm-with-values.yaml
                name: cmp-plugin
  {{ if $systemEnabled }}
        envFrom:
          - secretRef:
              name: avp-config
        resources:
          limits:
            cpu: 8
            memory: 8Gi
      extraObjects:
        - apiVersion: v1
          kind: Secret
          metadata:
            name: avp-config
            namespace: beget-argocd
          type: Opaque
          stringData:
            AVP_TYPE: "vault"
            AVP_AUTH_TYPE: "k8s"
            VAULT_ADDR: "http://vault.beget-vault.svc.cluster.local:8200"
            AVP_K8S_ROLE: "credentials-ro"
  {{ end }}
    monitoring:
  {{ if $infraVMOperatorReady }}
      enabled: true
  {{ end }}
      secureService:
      {{ if $certManagerReady }}
        enabled: true
      {{ end }}
        issuer:
          name: selfsigned-cluster-issuer
  {{ if $istioBaseReady }}
    istio:
      virtualService:
        enabled: true
        gateways:
          - beget-istio-gw/default
        hosts:
          - "*"
        http:
          name: argocd
          route:
            host: argocd-server
            port: 443
      destinationRule:
        enabled: true
        host: argocd-server
        trafficPolicy:
          tls:
            mode: SIMPLE
            insecureSkipVerify: true
  {{ end }}
  ` }}
{{- end -}}

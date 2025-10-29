{{- define "xclusterComponents.addonsetIii.argocd" -}}
  {{- printf `
argocd:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsArgocd
  finalizerDisabled: false
  namespace: beget-argocd
  version: v1alpha1
  {{ if and $certManagerReady }}
  pluginName: kustomize-helm-with-values
  {{ else }}
  pluginName: helm-with-values
  {{ end }}
  values:
    argo-cd:
      configs:
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
                    if [ -z "${ARGOCD_ENV_RELEASE_NAME}" ]; then
                        ARGOCD_ENV_RELEASE_NAME="${ARGOCD_APP_NAME#*_}"
                    fi
                    echo "${ARGOCD_ENV_HELM_VALUES}" | base64 -d > ./additionalValues.yaml
                    helm template "${ARGOCD_ENV_RELEASE_NAME}" --include-crds -n "${ARGOCD_APP_NAMESPACE}" -f ./additionalValues.yaml .
            kustomize-helm-with-values:
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
                        find . -name 'values.yaml' &&
                        find . -name 'patches/kustomization.yaml';
                      fi
              generate:
                command:
                  - bash
                  - '-c'
                  - |
                    if [ -z "${ARGOCD_ENV_RELEASE_NAME}" ]; then
                        ARGOCD_ENV_RELEASE_NAME="${ARGOCD_APP_NAME#*_}"
                    fi
                    echo "${ARGOCD_ENV_HELM_VALUES}" | base64 -d > ./additionalValues.yaml
                    helm template "${ARGOCD_ENV_RELEASE_NAME}" --include-crds -n "${ARGOCD_APP_NAMESPACE}" -f ./additionalValues.yaml . > ./patches/base.yaml;
                    kustomize build ./patches
  {{ if $systemEnabled }}
            argocd-vault-plugin-helm-with-values:
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
                        find . -name 'values.yaml';
                      fi
              generate:
                command:
                  - bash
                  - '-c'
                  - |
                    if [ -z "${ARGOCD_ENV_RELEASE_NAME}" ]; then
                        ARGOCD_ENV_RELEASE_NAME="${ARGOCD_APP_NAME#*_}"
                    fi
                    echo "${ARGOCD_ENV_HELM_VALUES}" | base64 -d > ./additionalValues.yaml
                    helm template "${ARGOCD_ENV_RELEASE_NAME}" --include-crds -n "${ARGOCD_APP_NAMESPACE}" -f ./additionalValues.yaml . |
                    argocd-vault-plugin generate -s beget-argocd:avp-config -
  {{ end }}
        secret:
          argocdServerAdminPassword: {{ $argsArgocdServerAdminPassword }}
          argocdServerAdminCreationTimestamp: {{ $xRCreationTimestamp }}
      redisSecretInit:
        enabled: false
      repoServer:
        volumes:
          - configMap:
              name: argocd-cmp-cm
            name: cmp-plugin
          - name: custom-tools
            emptyDir: {}
        # dnsPolicy: "ClusterFirstWithHostNet"
        extraContainers:
          - name: helm-with-values
            command: [/var/run/argocd/argocd-cmp-server]
            image: "quay.io/argoproj/argocd:v2.14.15"
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
          - name: kustomize-helm-with-values
            command: [/var/run/argocd/argocd-cmp-server]
            image: "quay.io/argoproj/argocd:v2.14.15"
            securityContext:
              runAsNonRoot: true
              runAsUser: 999
            volumeMounts:
              - mountPath: /var/run/argocd
                name: var-files
              - mountPath: /home/argocd/cmp-server/plugins
                name: plugins
              - mountPath: /home/argocd/cmp-server/config/plugin.yaml
                subPath: kustomize-helm-with-values.yaml
                name: cmp-plugin
  {{ if $systemEnabled }}
          - name: argocd-vault-plugin-helm-with-values
            command: [/var/run/argocd/argocd-cmp-server]
            image: "quay.io/argoproj/argocd:v2.14.15"
            securityContext:
              runAsNonRoot: true
              runAsUser: 999
            volumeMounts:
              - mountPath: /var/run/argocd
                name: var-files
              - mountPath: /home/argocd/cmp-server/plugins
                name: plugins
              - mountPath: /home/argocd/cmp-server/config/plugin.yaml
                subPath: argocd-vault-plugin-helm-with-values.yaml
                name: cmp-plugin
              - name: custom-tools
                subPath: argocd-vault-plugin
                mountPath: /usr/local/bin/argocd-vault-plugin
        envFrom:
          - secretRef:
              name: avp-config
        volumeMounts:
          - name: custom-tools
            subPath: argocd-vault-plugin
            mountPath: /usr/local/bin/argocd-vault-plugin
        initContainers:
          - name: download-argocd-vault-plugin
            image: "dmkolbin/dowloader"
            command: [sh, -c]
            args:
              - >-
                curl -Lk -o /custom-tools/argocd-vault-plugin https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v1.18.1/argocd-vault-plugin_1.18.1_linux_amd64 &&
                chmod +x /custom-tools/argocd-vault-plugin
            volumeMounts:
              - mountPath: /custom-tools
                name: custom-tools
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
      keepKey: ""
  {{ if $infraVMOperatorReady }}
      enabled: true
  {{ end }}
  {{ if $certManagerReady }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  {{ end }}
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

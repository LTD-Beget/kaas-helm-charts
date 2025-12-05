{{- define "addons.argocd" }}
name: Argocd
debug: false
path: helm-chart-sources/argocd
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "argocd" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: kustomize-helm-with-values
default: |
  argo-cd:
    crds:
      install: true
    global:
      deploymentStrategy:
        type: RollingUpdate
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    configs:
      cm:
        application.resourceTrackingMethod: annotation
        reposerver.default.cache.expiration: 8h0m0s
        reposerver.repo.cache.expiration: 8h0m0s
        resource.compareoptions: |
          ignoreAggregatedRoles: true
        resource.customizations: |
          "*.upbound.io/*":
            health.lua: |
              health_status = {
                status = "Progressing",
                message = "Provisioning ..."
              }

              local function contains (table, val)
                for i, v in ipairs(table) do
                  if v == val then
                    return true
                  end
                end
                return false
              end

              local has_no_status = {
                "ProviderConfig",
                "ProviderConfigUsage"
              }

              if obj.status == nil or next(obj.status) == nil and contains(has_no_status, obj.kind) then
                health_status.status = "Healthy"
                health_status.message = "Resource is up-to-date."
                return health_status
              end

              if obj.status == nil or next(obj.status) == nil or obj.status.conditions == nil then
                if obj.kind == "ProviderConfig" and obj.status.users ~= nil then
                  health_status.status = "Healthy"
                  health_status.message = "Resource is in use."
                  return health_status
                end
                return health_status
              end

              for i, condition in ipairs(obj.status.conditions) do
                if condition.type == "LastAsyncOperation" then
                  if condition.status == "False" then
                    health_status.status = "Degraded"
                    health_status.message = condition.message
                    return health_status
                  end
                end

                if condition.type == "Synced" then
                  if condition.status == "False" then
                    health_status.status = "Degraded"
                    health_status.message = condition.message
                    return health_status
                  end
                end

                if condition.type == "Ready" then
                  if condition.status == "True" then
                    health_status.status = "Healthy"
                    health_status.message = "Resource is up-to-date."
                    return health_status
                  end
                end
              end

              return health_status

          "*.crossplane.io/*":
            health.lua: |
              health_status = {
                status = "Progressing",
                message = "Provisioning ..."
              }

              local function contains (table, val)
                for i, v in ipairs(table) do
                  if v == val then
                    return true
                  end
                end
                return false
              end

              local has_no_status = {
                "Composition",
                "CompositionRevision",
                "DeploymentRuntimeConfig",
                "ControllerConfig",
                "ProviderConfig",
                "ProviderConfigUsage"
              }
              if obj.status == nil or next(obj.status) == nil and contains(has_no_status, obj.kind) then
                  health_status.status = "Healthy"
                  health_status.message = "Resource is up-to-date."
                return health_status
              end

              if obj.status == nil or next(obj.status) == nil or obj.status.conditions == nil then
                if obj.kind == "ProviderConfig" and obj.status.users ~= nil then
                  health_status.status = "Healthy"
                  health_status.message = "Resource is in use."
                  return health_status
                end
                return health_status
              end

              for i, condition in ipairs(obj.status.conditions) do
                if condition.type == "LastAsyncOperation" then
                  if condition.status == "False" then
                    health_status.status = "Degraded"
                    health_status.message = condition.message
                    return health_status
                  end
                end

                if condition.type == "Synced" then
                  if condition.status == "False" then
                    health_status.status = "Degraded"
                    health_status.message = condition.message
                    return health_status
                  end
                end

                if contains({"Ready", "Healthy", "Offered", "Established"}, condition.type) then
                  if condition.status == "True" then
                    health_status.status = "Healthy"
                    health_status.message = "Resource is up-to-date."
                    return health_status
                  end
                end
              end

              return health_status
        resource.customizations.ignoreDifferences.admissionregistration.k8s.io_MutatingWebhookConfiguration: |
          jqPathExpressions:
          - '.webhooks[]?.clientConfig.caBundle'
        resource.customizations.ignoreDifferences.admissionregistration.k8s.io_ValidatingWebhookConfiguration: |
          jqPathExpressions:
          - '.webhooks[]?.clientConfig.caBundle'
        resource.customizations.ignoreDifferences.all: |
          jqPathExpressions:
          - '.spec.template.spec.containers[].volumeMounts[] | select(.name == "ssl-certs")'
          - '.spec.template.spec.volumes[] | select(.name == "ssl-certs")'
          - '.spec.template.spec.securityContext'
          - '.spec.template.spec.containers[].securityContext'
          - '.spec.template.spec.initContainers[].securityContext'
          - '.spec.replicas'
        resource.customizations.ignoreDifferences.kyverno.io_ClusterPolicy: |
          jqPathExpressions:
          - '.spec.rules[] | select(.name|test("autogen-."))'
        resource.customizations.ignoreDifferences.kyverno.io_Policy: |
          jqPathExpressions:
          - '.spec.rules[] | select(.name|test("autogen-."))'
        timeout.reconciliation: 10s
        timeout.reconciliation.jitter: 10s
        kustomize.buildOptions: --enable-helm
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
      params:
        application.namespaces: '*'
        applicationsetcontroller.allowed.scm.providers: https://gitlab.beget.ru
        applicationsetcontroller.namespaces: '*'
        # repo.server: 127.0.0.1:8081
        # redis.server: 127.0.0.1:6379
        controller.sharding.algorithm: round-robin
        server.basehref: /argocd
        server.rootpath: /argocd
        server.staticassets: /shared/app
      secret:
        argocdServerAdminPassword: "$2a$10$3MqvSHzzSj38YYNFDrkolONgKe9ejuphtk1Qe5gWNdm9ILVQYUOma"
    dex:
      enabled: false
    notifications:
      enabled: false
    redis-ha:
      enabled: false
    redis:
      enabled: true
      image:
        imagePullPolicy: IfNotPresent
      replicas: 1
      # hostNetwork: true
      exporter:
        enabled: true
        resources:
          limits:
            cpu: 200m
            ephemeral-storage: 10Mi
            memory: 128Mi
          requests:
            cpu: 100m
            ephemeral-storage: 10Mi
            memory: 64Mi
      metrics:
        enabled: true
      resources:
        limits:
          cpu: 200m
          ephemeral-storage: 100Mi
          memory: 196Mi
        requests:
          cpu: 100m
          ephemeral-storage: 100Mi
          memory: 128Mi
    redisSecretInit:
      enabled: false
      image:
        imagePullPolicy: IfNotPresent
      # hostNetwork: true
      extraArgs:
        - --kubeconfig
        - /etc/kubernetes/admin.conf
      volumes:
        - hostPath:
            path: /etc/kubernetes/admin.conf
            type: FileOrCreate
          name: admin-conf
      volumeMounts:
        - mountPath: /etc/kubernetes/admin.conf
          name: admin-conf
      containerSecurityContext:
        runAsNonRoot: false
        runAsUser: 0
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
        seccompProfile:
          type: RuntimeDefault
      resources:
        limits:
          cpu: 20m
          ephemeral-storage: 10Mi
          memory: 64Mi
        requests:
          cpu: 10m
          ephemeral-storage: 10Mi
          memory: 32Mi
    repoServer:
      image:
        imagePullPolicy: IfNotPresent
      # hostNetwork: true
      containerSecurityContext:
        runAsNonRoot: true
        runAsUser: 999
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
        seccompProfile:
          type: RuntimeDefault
      emptyDir:
        sizeLimit: 10Gi
      metrics:
        enabled: true
      rbac:
      - apiGroups:
        - '*'
        resources:
        - '*'
        verbs:
        - '*'
      replicas: 1
      resources:
        limits:
          ephemeral-storage: 1Gi
          memory: 1Gi
        requests:
          cpu: 100m
          ephemeral-storage: 1Gi
          memory: 150Mi
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app.kubernetes.io/name: argocd-redis
              topologyKey: kubernetes.io/hostname
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
      volumes:
        - configMap:
            name: argocd-cmp-cm
          name: cmp-plugin
    server:
      image:
        imagePullPolicy: IfNotPresent
      # hostNetwork: true
      containerSecurityContext:
        runAsNonRoot: false
        runAsUser: 0
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
        seccompProfile:
          type: RuntimeDefault
      extraArgs:
        # - --repo-server
        # - 127.0.0.1:8081
        # - --redis
        # - 127.0.0.1:6379
        - --kubeconfig
        - /etc/kubernetes/admin.conf
      volumes:
        - hostPath:
            path: /etc/kubernetes/admin.conf
            type: FileOrCreate
          name: admin-conf
      volumeMounts:
        - mountPath: /etc/kubernetes/admin.conf
          name: admin-conf
      emptyDir:
        sizeLimit: 500Mi
      ingress:
        enabled: false
      metrics:
        enabled: true
      replicas: 1
      resources:
        limits:
          ephemeral-storage: 100Mi
        requests:
          cpu: 50m
          ephemeral-storage: 100Mi
          memory: 64Mi
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app.kubernetes.io/name: argocd-redis
              topologyKey: kubernetes.io/hostname
    controller:
      image:
        imagePullPolicy: IfNotPresent
      # hostNetwork: true
      containerSecurityContext:
        runAsNonRoot: false
        runAsUser: 0
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
        seccompProfile:
          type: RuntimeDefault
      extraArgs:
        # - --repo-server
        # - 127.0.0.1:8081
        # - --redis
        # - 127.0.0.1:6379
        - --kubeconfig
        - /etc/kubernetes/admin.conf
      volumes:
        - hostPath:
            path: /etc/kubernetes/admin.conf
            type: FileOrCreate
          name: admin-conf
      volumeMounts:
        - mountPath: /etc/kubernetes/admin.conf
          name: admin-conf
      emptyDir:
        sizeLimit: 500Mi
      metrics:
        enabled: true
      replicas: 1
      resources:
        limits:
          ephemeral-storage: 500Mi
        requests:
          cpu: 100m
          ephemeral-storage: 500Mi
          memory: 64Mi
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app.kubernetes.io/name: argocd-redis
              topologyKey: kubernetes.io/hostname
    applicationSet:
      replicas: 0
      image:
        imagePullPolicy: IfNotPresent
      allowAnyNamespace: true
      emptyDir:
        sizeLimit: 500Mi
      metrics:
        enabled: true
      resources:
        limits:
          cpu: 400m
          ephemeral-storage: 100Mi
          memory: 256Mi
        requests:
          cpu: 10m
          ephemeral-storage: 100Mi
          memory: 32Mi
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app.kubernetes.io/name: argocd-redis
              topologyKey: kubernetes.io/hostname
{{- end }}

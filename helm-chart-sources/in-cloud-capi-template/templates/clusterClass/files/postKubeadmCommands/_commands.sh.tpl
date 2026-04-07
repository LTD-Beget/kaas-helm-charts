{{- define "in-cloud-capi-template.files.postKubeadmCommands.commands.sh" -}}
- path: /etc/default/postKubeadmCommand/commands.sh
  owner: root:root
  permissions: '0755'
  content: |
    #!/bin/bash

    KUBECONFIG=/etc/kubernetes/admin.conf
    export KUBECONFIG

    kubectl get namespace {{ $.Values.companyPrefix }}-system >/dev/null 2>&1 || kubectl create namespace {{ $.Values.companyPrefix }}-system

    DONE_FILE=/var/lib/{{ $.Values.companyPrefix }}/addons-bootstrap.done
    mkdir -p /var/lib/{{ $.Values.companyPrefix }}

    #Адрес kube-Api
    KUBEAPI_HOST=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}' --minify=true | awk -F/ '{print $NF}' | awk -F: '{print $1}')

    # Сколько control-plane нод уже в кластере
    CP_COUNT=$(kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes \
      -l node-role.kubernetes.io/control-plane \
      --no-headers 2>/dev/null | wc -l)

    if [ "$CP_COUNT" -ne 1 ]; then
      echo "Not first control-plane node, skipping helm install"
      exit 0
    fi

    echo "First control-plane node detected → running helm install"

    # ---- (1) вытаскиваем endpoint host/port из admin.conf ----
    APISERVER_URL="$(kubectl --kubeconfig="$KUBECONFIG" config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
    if [[ -z "$APISERVER_URL" ]]; then
      logger -t "$LOG_TAG" "[ERROR] can't read apiserver url from $KUBECONFIG"
      exit 1
    fi

    CLUSTER_ENDPOINT_HOST="$(echo "$APISERVER_URL" | sed -E 's#https?://([^:/]+).*#\1#')"
    CLUSTER_ENDPOINT_PORT="$(echo "$APISERVER_URL" | sed -E 's#.*:([0-9]+)$#\1#')"
    if [[ "$CLUSTER_ENDPOINT_PORT" == "$APISERVER_URL" ]]; then
      CLUSTER_ENDPOINT_PORT=6443
    fi

    export CLUSTER_ENDPOINT_HOST
    export CLUSTER_ENDPOINT_PORT
    export CLUSTER_DNS_HOST="{{`{{ .clusterDnsSvc }}`}}"

    logger -t "$LOG_TAG" "[INFO] apiserver endpoint: ${CLUSTER_ENDPOINT_HOST}:${CLUSTER_ENDPOINT_PORT}"

    # ---- (2) рабочая директория ----
    TEMPDIRCLUSTER="$(mktemp -d)"
    logger -t "$LOG_TAG" "[INFO] workdir: $TEMPDIRCLUSTER"
    cd "$TEMPDIRCLUSTER"

    # ---- (3) helm add + update ----
    logger -t "$LOG_TAG" "[INFO] adding {{ $.Values.companyPrefix }} charts repo..."

    helm repo add {{ $.Values.companyPrefix }} https://blog.{{ $.Values.companyDomain }}/kaas-helm-charts/

    logger -t "$LOG_TAG" "[INFO] updating {{ $.Values.companyPrefix }} charts repo..."
    helm repo update {{ $.Values.companyPrefix }}

    # ---- (4) ставим аддоны через helm ----
    logger -t "$LOG_TAG" "[INFO] install/upgrade cilium..."

    echo "System cluster detected → waiting for InternalIP"
    kubectl wait --timeout=-1s node -l node-role.kubernetes.io/control-plane \
      --for=jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}'

    cat <<EOF | helm install cilium {{ $.Values.companyPrefix }}/cilium -n {{ $.Values.companyPrefix }}-cilium --create-namespace --version 1.18.5-1 -f -
    cilium:
      ciliumEndpointSlice:
        enabled: true
      dnsPolicy: ClusterFirstWithHostNet
      envoy:
        enabled: false
      hubble:
        enabled: false
      k8sServiceHost: ${CLUSTER_ENDPOINT_HOST}
      k8sServicePort: ${CLUSTER_ENDPOINT_PORT}
      kubeProxyReplacement: true
      operator:
        replicas: 1
        tolerations:
        - operator: Exists
          effect: NoSchedule
      ipam:
        operator:
          clusterPoolIPv4MaskSize: {{`{{ .clusterPodCidrMaskSize }}`}}
          clusterPoolIPv4PodCIDRList: '{{`{{ .clusterPodCidr }}`}}'

      resources:
        requests:
          cpu: 100m
          memory: 100Mi
      tls:
        readSecretsOnlyFromSecretsNamespace: false
        secretSync:
          enabled: false
        secretsNamespace:
          create: false
          name: null
      tolerations:
      - operator: Exists
        effect: NoSchedule
    EOF

    logger -t "$LOG_TAG" "[INFO] install/upgrade coredns..."
    cat <<EOF | helm install coredns {{ $.Values.companyPrefix }}/coredns -n {{ $.Values.companyPrefix }}-coredns --create-namespace --version 1.28.0-1 -f -
    coredns:
      livenessProbe:
        initialDelaySeconds: 10
        periodSeconds: 5
        timeoutSeconds: 3
        failureThreshold: 10
      readinessProbe:
        initialDelaySeconds: 10
        periodSeconds: 5
        timeoutSeconds: 3
        failureThreshold: 10
      priorityClassName: system-cluster-critical
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
      rollingUpdate:
        maxUnavailable: 35%
        maxSurge: 1
      securityContext:
        readOnlyRootFilesystem: true
        runAsNonRoot: false
        runAsUser: 0
      servers:
      - plugins:
        - configBlock: |-
            pods verified
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
          name: kubernetes
          parameters: cluster.local in-addr.arpa ip6.arpa
        - configBlock: to *
          name: transfer
        - name: loop
        - name: reload
        - name: errors
        - name: ready
        - name: loadbalance
          parameter: round_robin
        - name: forward
          parameters: . /etc/resolv.conf
        - name: cache
          parameters: 30
        - name: prometheus
          parameters: 0.0.0.0:9153
        - configBlock: class all
          name: log
        - configBlock: lameduck 5s
          name: health
        port: 53
        zones:
        - zone: cluster.local.
      - plugins:
        - name: loop
        - name: reload
        - name: errors
        - name: ready
        - name: loadbalance
          parameter: round_robin
        - configBlock: force_tcp
          name: forward
          parameters: . /etc/resolv.conf
        - name: cache
          parameters: 30
        - name: prometheus
          parameters: 0.0.0.0:9153
        - configBlock: class all
          name: log
        - configBlock: lameduck 5s
          name: health
        port: 53
        zones:
        - zone: .
      service:
        clusterIP: ${CLUSTER_DNS_HOST}
      serviceAccount:
        create: true
        name: coredns
      tolerations:
      - operator: Exists
        effect: NoSchedule
    EOF

    kubectl wait --timeout=-1s --for=condition=Ready pod -l app.kubernetes.io/instance=coredns -n {{ $.Values.companyPrefix }}-coredns

    logger -t "$LOG_TAG" "[INFO] install/upgrade argocd..."
    cat <<'EOF' | helm install argocd {{ $.Values.companyPrefix }}/argo-cd -n {{ $.Values.companyPrefix }}-argocd --create-namespace --version 9.4.15-1 -f -
    argo-cd:
      fullnameOverride: "argocd"
      applicationSet:
        replicas: 0
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
          kustomize.buildOptions: --enable-helm
          timeout.reconciliation: 10s
          timeout.reconciliation.jitter: 10s
          url: "https://localhost/argocd"
        cmp:
          create: true
          plugins:
            helm-with-values:
              allowConcurrency: true
              discover:
                find:
                  command:
                  - bash
                  - -c
                  - |
                    if [ -n "${ARGOCD_ENV_HELM_VALUES+set}" ] ; then
                      find . -name 'Chart.yaml' &&
                      find . -name 'values.yaml'
                    fi
              generate:
                command:
                - bash
                - -c
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
                      echo "$OUTPUT" | argocd-vault-plugin generate -s {{ $.Values.companyPrefix }}-argocd:avp-config -
                  else
                      echo "$OUTPUT"
                  fi
              lockRepo: false
        params:
          application.namespaces: '*'
          applicationsetcontroller.allowed.scm.providers: https://gitlab.{{ $.Values.companyPrefix }}.ru
          applicationsetcontroller.namespaces: '*'
          # repo.server: 127.0.0.1:8081
          # redis.server: 127.0.0.1:6379
          controller.sharding.algorithm: round-robin
          server.basehref: /argocd
          server.rootpath: /argocd
          server.staticassets: /shared/app
        secret:
          argocdServerAdminPassword: "$2a$10$3MqvSHzzSj38YYNFDrkolONgKe9ejuphtk1Qe5gWNdm9ILVQYUOma"
          argocdServerAdminPasswordMtime: "2025-10-30T16:30:50Z"
      controller:
        dynamicClusterDistribution: true
        image:
          imagePullPolicy: IfNotPresent
        replicas: 1
        resources:
          limits:
            cpu: "4"
            ephemeral-storage: 10Gi
          requests:
            cpu: 1
            ephemeral-storage: 500Mi
            memory: 1Gi
        volumes:
          - hostPath:
              path: /etc/kubernetes/admin.conf
              type: FileOrCreate
            name: admin-conf
        volumeMounts:
          - mountPath: /etc/kubernetes/admin.conf
            name: admin-conf
      crds:
          install: true
      dex:
        enabled: false
      extraObjects:
      - apiVersion: v1
        kind: Secret
        metadata:
          name: avp-config
          namespace: {{ $.Values.companyPrefix }}-argocd
        stringData:
          AVP_AUTH_TYPE: k8s
          AVP_K8S_ROLE: credentials-ro
          AVP_TYPE: vault
          VAULT_ADDR: http://vault.{{ $.Values.companyPrefix }}-vault.svc.cluster.local:8200
        type: Opaque
      global:
        deploymentStrategy:
          type: RollingUpdate
        tolerations:
        - operator: Exists
          effect: NoSchedule
      notifications:
        enabled: false
      redis:
        resources:
          limits:
            cpu: 1
            memory: 1Gi
          requests:
            cpu: 100m
            ephemeral-storage: 100Mi
            memory: 128Mi
      redisSecretInit:
        enabled: true
      repoServer:
        envFrom:
        - secretRef:
            name: avp-config
        extraContainers:
        - command:
          - /var/run/argocd/argocd-cmp-server
          image: dmkolbin/argocd-with-utils:v2.14.10
          name: helm-with-values
          securityContext:
            runAsNonRoot: true
            runAsUser: 999
          volumeMounts:
          - mountPath: /var/run/argocd
            name: var-files
          - mountPath: /home/argocd/cmp-server/plugins
            name: plugins
          - mountPath: /home/argocd/cmp-server/config/plugin.yaml
            name: cmp-plugin
            subPath: helm-with-values.yaml
        resources:
          limits:
            cpu: 8
            ephemeral-storage: 10Gi
            memory: 8Gi
          requests:
            cpu: 100m
            ephemeral-storage: 10Gi
            memory: 128Mi
        volumes:
        - configMap:
            name: argocd-cmp-cm
          name: cmp-plugin
      server:
        volumes:
          - hostPath:
              path: /etc/kubernetes/admin.conf
              type: FileOrCreate
            name: admin-conf
        volumeMounts:
          - mountPath: /etc/kubernetes/admin.conf
            name: admin-conf
    EOF

    logger -t "$LOG_TAG" "[INFO] install/upgrade addon-operator..."
    cat <<EOF | helm install addons-operator {{ $.Values.companyPrefix }}/addon-operator -n {{ $.Values.companyPrefix }}-addons-operator --create-namespace --version 0.1.2 -f -
    certManager:
      enable: false
    manager:
      env:
      - name: ENABLE_WEBHOOKS
        value: false
      image:
        repository: prorobotech/addons-operator
        pullPolicy: IfNotPresent
      tolerations:
      - operator: Exists
        effect: NoSchedule
    metrics:
      enable: false
      port: 8443
    webhook:
      enable: false
    EOF

    kubectl wait --timeout=-1s --for=condition=Ready pod -l app.kubernetes.io/component=application-controller -n {{ $.Values.companyPrefix }}-argocd
    kubectl wait --timeout=-1s --for=condition=Ready pod -l app.kubernetes.io/component=redis -n {{ $.Values.companyPrefix }}-argocd
    kubectl wait --timeout=-1s --for=condition=Ready pod -l app.kubernetes.io/component=repo-server -n {{ $.Values.companyPrefix }}-argocd
    kubectl wait --timeout=-1s --for=condition=Ready pod -l app.kubernetes.io/component=server -n {{ $.Values.companyPrefix }}-argocd

    # ---- (5) apply addonset static-manifest ----

    kubectl wait --timeout=-1s --for=jsonpath='{.data.addonRevision}' cm -n {{ $.Values.companyPrefix }}-system parameters-infra
    kubectl wait --timeout=-1s --for=jsonpath='{.data.companyExternalChartRegistry}' cm -n {{ $.Values.companyPrefix }}-system parameters-infra
    kubectl wait --timeout=-1s --for=jsonpath='{.data.companyPrefix}' cm -n {{ $.Values.companyPrefix }}-system parameters-infra

    params=$(kubectl get cm -n {{ $.Values.companyPrefix }}-system parameters-infra -o json | jq '.data')
    addonRevision=$(jq -r '.addonRevision' <<< $params)
    companyExternalChartRegistry=$(jq -r '.companyExternalChartRegistry' <<< $params)
    companyPrefix=$(jq -r '.companyPrefix' <<< $params)

    helm install bootstrap \
      {{ $.Values.companyPrefix }}/bootstrap \
      --version ${addonRevision} \
      --set companyPrefix=${companyPrefix} \
      --set companyExternalChartRegistry=${companyExternalChartRegistry} \
      -n {{ $.Values.companyPrefix }}-system

    logger -t "$LOG_TAG" "[INFO] applying Addon CR..."

    date -Is > "$DONE_FILE"
    logger -t "$LOG_TAG" "[INFO] addons bootstrap done: $(cat "$DONE_FILE")"

{{- end }}

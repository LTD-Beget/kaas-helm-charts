{{- define "addons.common.application.gotemplates.object" }}
  {{- $name := printf "%s" .name }}
  {{- $singular := $name | lower}}
  {{- $singularCamel := include "camelLower" $name }}
  {{- $singularKebab := kebabcase $name }}
  {{- $singularSnake := snakecase $name }}
  {{- $pluralName := printf "%ss" $name }}
  {{- $plural := printf "%ss" $singular }}
  {{- $pluralCamel := printf "%ss" $singularCamel }}
  {{- $pluralKebab := printf "%ss" $singularKebab }}
  {{- $pluralSnake := printf "%ss" $singularSnake }}
  {{- $appName := printf "%sApp" $singularCamel }}
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  name: {{ "\"{{ $name }}-app\"" }}
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: {{ $appName }}
    deployed.in-cloud.io/status: {{ "\"{{ $appReady }}\"" }}
    gotemplating.fn.crossplane.io/ready: {{ "\"{{ $appReady }}\"" }}
spec:
  providerConfigRef:
    name: {{ "\"{{ $providerConfigRefName }}\"" }}
  managementPolicies:
  - '*'
  deletionPolicy: Delete
  forProvider:
    manifest:
      apiVersion: argoproj.io/v1alpha1
      kind: Application
      metadata:
        name: {{ "\"{{ $name }}\"" }}
        namespace: {{ "\"{{ $argocdNamespace }}\"" }}
        labels:
          cluster.x-k8s.io/cluster-name: {{ "\"{{ $clusterName }}\"" }}
        annotations:
          argocd.argoproj.io/tracking-id: {{ "\"{{ $trackingID }}\"" }}
          deployed.in-cloud.io/status: {{ "\"{{ $appReady }}\"" }}
        finalizers:
          - resources-finalizer.argocd.argoproj.io
      spec:
        project: {{ "\"{{ $argocdProject }}\"" }}
        destination:
          namespace: {{ "\"{{ $argocdDestinationNamespace }}\"" }}
          name: {{ "\"{{ $argocdDestinationName }}\"" }}
        syncPolicy:
          managedNamespaceMetadata:
            labels:
              in-cloud.io/clusterName: {{ "\"{{ $clusterName }}\"" }}
          automated:
            prune: true
            selfHeal: true
          syncOptions:
          - CreateNamespace=true
        source:
          path: {{ "\"{{ $path }}\"" }}
          chart: {{ "\"{{ $chart }}\"" }}
          repoURL: {{ "\"{{ $repoURL }}\"" }}
          targetRevision: {{ "\"{{ $targetRevision }}\"" }}
          {{- if .pluginName }}
          plugin:
            name: {{ "\"{{ $pluginName }}\"" }}
            env:
              - name: "HELM_VALUES"
                value: |-
                  {{ "{{ $mergedValues := merge $immutableValues $userValues $defaultValues }}" }}
                  {{ "{{ $mergedValues | toYaml | nindent 18 }}" }}
              - name: "RELEASE_NAME"
                value: {{ "\"{{ $argocdReleaseName }}\"" }}
          {{- else }}
          helm:
            releaseName: {{ "\"{{ $argocdReleaseName }}\"" }}
            values: |-
              {{ "{{ $mergedValues := merge $immutableValues $userValues $defaultValues }}" }}
              {{ "{{ $mergedValues | toYaml | nindent 14 }}" }}
          {{- end }}
  readiness:
    policy: DeriveFromCelQuery
    celQuery: >
      object.metadata.annotations['deployed.in-cloud.io/status'] == 'True'
  watch: true
{{- end }}

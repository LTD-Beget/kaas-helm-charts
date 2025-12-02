{{ define "environment.xaddonset.patches" }}

  {{- $commonArgocdDestinationName      := list "common.argocd.destination.name"      "%s" }}
  {{- $commonArgocdNamespace            := list "common.argocd.namespace"             "%s" }}
  {{- $commonArgocdProject              := list "common.argocd.project"               "%s" }}
  {{- $commonClusterName                := list "common.cluster.name"                 "%s" }}
  {{- $commonClusterHost                := list "common.cluster.host"                 "%s" }}
  {{- $commonClusterPort                := list "common.cluster.port"                 "%.0f" }}
  {{- $commonProviderConfigRefName      := list "common.providerConfigRef.name"       "%s" }}
  {{- $commonTrackingID                 := list "common.trackingID"                   "%s" }}
  {{- $commonXcluster                   := list "common.xcluster"                     "%s" }}

- toFieldPath: base.name
  fromFieldPath: metadata.name
  type: FromCompositeFieldPath

- toFieldPath: base.namespace
  fromFieldPath: spec.common.namespace
  type: FromCompositeFieldPath

- toFieldPath: base.customer
  fromFieldPath: spec.customer
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonArgocdDestinationName 0 }}
  fromFieldPath: spec.common.argocd.destination.name
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonArgocdDestinationName 1 | quote }}
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonArgocdNamespace 0 }}
  fromFieldPath: spec.common.argocd.namespace
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonArgocdNamespace 1 | quote }}
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonArgocdProject 0 }}
  fromFieldPath: spec.common.argocd.project
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonArgocdProject 1 | quote }}
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonClusterName 0 }}
  fromFieldPath: spec.common.cluster.name
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonClusterName 1 | quote }}
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonClusterHost 0 }}
  fromFieldPath: spec.common.cluster.host
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonClusterHost 1 | quote }}
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonClusterPort 0 }}
  fromFieldPath: spec.common.cluster.port
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonClusterPort 1 | quote }}
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonProviderConfigRefName 0 }}
  fromFieldPath: spec.common.providerConfigRef.name
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonProviderConfigRefName 1 | quote }}
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonTrackingID 0 }}
  fromFieldPath: spec.common.trackingID
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonTrackingID 1 | quote }}
  type: FromCompositeFieldPath

- toFieldPath: {{ index $commonXcluster 0 }}
  fromFieldPath: spec.common.xcluster
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ index $commonXcluster 1 | quote }}
  type: FromCompositeFieldPath

{{- end }}

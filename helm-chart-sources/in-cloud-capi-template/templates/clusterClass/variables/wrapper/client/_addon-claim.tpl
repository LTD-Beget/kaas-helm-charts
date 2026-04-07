{{- define "in-cloud-capi-template.variables.wrapper.client.addonClaim" -}}

- name: argocdSourceTragetRevision
  required: false
  schema:
    openAPIV3Schema:
      default: "0.1.6"
      type: string

- name: {{ $.Values.companyPrefix}}CltControlplaneReplicas
  required: true
  schema:
    openAPIV3Schema:
      default: "1"
      type: string
- name: {{ $.Values.companyPrefix}}CltLoadBalancerListenerPort
  required: true
  schema:
    openAPIV3Schema:
      default: 26443
      type: integer

- name: {{ $.Values.companyPrefix}}TrackingId
  required: true
  schema:
    openAPIV3Schema:
      default: mocknsMock:argoproj.io/Application:mockns/mock
      type: string

- name: {{ $.Values.companyPrefix}}AppDestinationName
  required: true
  schema:
    openAPIV3Schema:
      default: mock-infra
      type: string

- name: {{ $.Values.companyPrefix}}AppDestinationNamespace
  required: false
  schema:
    openAPIV3Schema:
      default: {{ $.Values.companyPrefix }}-system
      type: string

- name: {{ $.Values.companyPrefix}}AppNamespace
  required: false
  schema:
    openAPIV3Schema:
      default: {{ $.Values.companyPrefix }}-argocd
      type: string

- name: {{ $.Values.companyPrefix}}AppProviderConfigRefName
  required: true
  schema:
    openAPIV3Schema:
      default: default
      type: string

- name: {{ $.Values.companyPrefix}}EtcdCaSecretName
  required: true
  schema:
    openAPIV3Schema:
      default: etcd
      type: string

- name: {{ $.Values.companyPrefix}}AppReleaseName
  required: false
  schema:
    openAPIV3Schema:
      default: client-cp
      type: string
{{- end -}}
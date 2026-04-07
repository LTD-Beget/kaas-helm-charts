{{- define "in-cloud-capi-template.variables.default.componentVersion" -}}
- name: containerdVersion
  required: false
  schema:
    openAPIV3Schema:
      default: 1.7.19
      type: string

- name: runcVersion
  required: false
  schema:
    openAPIV3Schema:
      default: v1.1.12
      type: string

- name: crictlVersion
  required: false
  schema:
    openAPIV3Schema:
      default: v1.30.0
      type: string

- name: etcdVersion
  required: false
  schema:
    openAPIV3Schema:
      default: v3.5.5
      type: string

- name: pauseVersion
  required: false
  schema:
    openAPIV3Schema:
      default: "3.9"
      type: string

- name: kubeadmVersion
  required: false
  schema:
    openAPIV3Schema:
      default: v1.30.4
      type: string

- name: kubectlVersion
  required: false
  schema:
    openAPIV3Schema:
      default: v1.30.4
      type: string

- name: kubeletVersion
  required: false
  schema:
    openAPIV3Schema:
      default: v1.30.4
      type: string
{{- end -}}

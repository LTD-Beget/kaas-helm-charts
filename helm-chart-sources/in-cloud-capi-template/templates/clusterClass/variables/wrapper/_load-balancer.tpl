{{- define "in-cloud-capi-template.variables.wrapper.loadBalancer" -}}
- name: {{ $.Values.companyPrefix}}ClusterLoadBalancerListenerInternal
  required: false
  schema:
    openAPIV3Schema:
      default: false
      type: boolean

# не используется
# - name: {{ $.Values.companyPrefix}}ClusterLoadBalancerBackendPort
#   required: false
#   schema:
#     openAPIV3Schema:
#       default: 6443
#       type: integer

- name: {{ $.Values.companyPrefix}}ClusterLoadBalancerType
  required: false
  schema:
    openAPIV3Schema:
      default: "external"
      type: string

- name: {{ $.Values.companyPrefix}}ClusterLoadBalancerListenerAddress
  required: true
  schema:
    openAPIV3Schema:
      default: 0.0.0.0
      type: string


- name: {{ $.Values.companyPrefix}}ClusterLoadBalancerListenerPorts
  required: false
  schema:
    openAPIV3Schema:
      type: array
      items:
        type: object
        required: ["from", "to"]
        properties:
          from:
            type: integer
            default: 6443
            minimum: 1
            maximum: 65535
          to:
            type: integer
            default: 6443
            minimum: 1
            maximum: 65535
          type:
            type: string
            enum: ["generic","controlPlane"]
            default: "generic"

- name: {{ $.Values.companyPrefix}}ClusterLoadBalancerHealthcheckThreshold
  required: false
  schema:
    openAPIV3Schema:
      default: 3
      type: integer


- name: {{ $.Values.companyPrefix}}ClusterLoadBalancerHealthcheckIntervalSec
  required: false
  schema:
    openAPIV3Schema:
      default: 30
      type: integer

- name: {{ $.Values.companyPrefix}}ClusterLoadBalancerHealthcheckTimeoutSec
  required: false
  schema:
    openAPIV3Schema:
      default: 10
      type: integer

{{- end -}}

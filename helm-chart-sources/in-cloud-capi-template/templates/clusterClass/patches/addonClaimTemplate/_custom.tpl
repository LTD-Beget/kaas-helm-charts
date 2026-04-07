{{- define "in-cloud-capi-template.patches.addonClaimTemplate.custom" -}}
- name: custom:AddonClaimTemplate
  definitions:
    - selector:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: AddonClaimTemplate
        matchResources:
          controlPlane: true
      jsonPatches:
        - op: replace
          path: /spec/template/spec/credentialRef/name
          valueFrom:
            template: '{{`{{ .`}}{{ $.Values.companyPrefix}}{{`ClusterClaimName }}`}}-infra-kubeconfig'
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneDestinationName
          valueFrom:
            variable: {{ $.Values.companyPrefix}}AppDestinationName
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneDestinationNamespace
          valueFrom:
            variable: {{ $.Values.companyPrefix}}AppDestinationNamespace
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneName
          valueFrom:
            template: '{{`{{ .builtin.cluster.name }}`}}-control-plane'
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneNamespace
          valueFrom:
            variable: {{ $.Values.companyPrefix}}AppNamespace
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneObjectName
          valueFrom:
            template: '{{`{{ .builtin.cluster.name }}`}}-control-plane-app'
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneProjectName
          value: default
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneProviderConfigRefName
          valueFrom:
            variable: {{ $.Values.companyPrefix}}AppProviderConfigRefName
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneReleaseName
          valueFrom:
            variable: {{ $.Values.companyPrefix}}AppReleaseName
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneSourceTargetRevision
          valueFrom:
            variable: argocdSourceTragetRevision
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneValueArgsClusterVersion
          valueFrom:
            variable: builtin.cluster.topology.version
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneValueArgsHost
          valueFrom:
            variable: {{ $.Values.companyPrefix}}ClusterLoadBalancerListenerAddress
        - op: replace
          path: /spec/template/spec/variables/argocdApplicationControlPlaneValueArgsPort
          valueFrom:
            variable: {{ $.Values.companyPrefix}}CltLoadBalancerListenerPort
        - op: replace
          path: /spec/template/spec/variables/certificatesCaName
          valueFrom:
            template: '{{`{{ .builtin.cluster.name }}`}}-ca'
        - op: replace
          path: /spec/template/spec/variables/certificatesEtcdName
          valueFrom:
            variable: {{ $.Values.companyPrefix}}EtcdCaSecretName
        - op: replace
          path: /spec/template/spec/variables/clusterName
          valueFrom:
            variable: builtin.cluster.name
        - op: replace
          path: /spec/template/spec/variables/controlPlaneReplicas
          valueFrom:
            variable: {{ $.Values.companyPrefix}}CltControlplaneReplicas
        - op: replace
          path: /spec/template/spec/variables/customer
          valueFrom:
            variable: {{ $.Values.companyPrefix}}ClusterCustomerLogin
        - op: replace
          path: /spec/template/spec/variables/serviceCidr
          valueFrom:
            template: '{{`{{ (index .builtin.cluster.network.services 0) }}`}}'
        - op: replace
          path: /spec/template/spec/variables/serviceCidrAddr
          valueFrom:
            template: '{{`{{- (split "/" (index .builtin.cluster.network.services 0))._0 -}}`}}'
        - op: replace
          path: /spec/template/spec/variables/serviceCidrBase
          valueFrom:
            template: '{{`{{ $octets := split "." (split "/" (index .builtin.cluster.network.services 0))._0 }}`}}{{`{{ printf "%s.%s.%s" $octets._0 $octets._1 $octets._2 }}`}}'
        - op: replace
          path: /spec/template/spec/variables/serviceCidrCoredns
          valueFrom:
            template: '{{`{{ $octets := split "." (split "/" (index .builtin.cluster.network.services 0))._0 }}`}}{{`{{ printf "%s.%s.%s.10" $octets._0 $octets._1 $octets._2 }}`}}'
        - op: replace
          path: /spec/template/spec/variables/serviceCidrApi
          valueFrom:
            template: '{{`{{ $octets := split "." (split "/" (index .builtin.cluster.network.services 0))._0 }}`}}{{`{{ printf "%s.%s.%s.1" $octets._0 $octets._1 $octets._2 }}`}}'
        - op: add
          path: /spec/template/spec/variables/trackingID
          valueFrom:
            variable: {{ $.Values.companyPrefix}}TrackingId
        - op: replace
          path: /spec/template/spec/variables/xcluster
          valueFrom:
            variable: {{ $.Values.companyPrefix}}ClusterClaimName
        - op: replace
          path: /spec/template/spec/variables/version
          valueFrom:
            variable: builtin.cluster.topology.version
        - op: replace
          path: /spec/template/spec/version
          valueFrom:
            variable: builtin.cluster.topology.version
{{- end -}}

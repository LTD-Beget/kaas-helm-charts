{{/*
Common patch: enable patches directory for a kubeadm configuration section.
Usage: include "...common.configurationPatches" (dict "configuration" "initConfiguration")
*/}}
{{- define "in-cloud-capi-template.patches.common.configurationPatches" -}}
- selector:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta2
    kind: KubeadmControlPlaneTemplate
    matchResources:
      controlPlane: true

  jsonPatches:
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/{{ .configuration }}/patches
      value:
        directory: /etc/kubernetes/patches
{{- end -}}

{{/*
Common patch: certSANs + extraArgs + extraVolumes for a clusterConfiguration component.

Params:
  component      – Values key (e.g. "controllerManager", "apiServer", "etcd")
  pathPrefix     – JSON-patch path segment (default: same as component, e.g. "etcd/local")
  certSANsFields – optional list of certSANs field names to render (e.g. list "certSANs")
  withExtraVolumes – set to false to skip extraVolumes (default: true)
  root           – $ (root context)

Usage:
  include "...common.clusterConfigurationComponent"
    (dict "component" "apiServer"
          "certSANsFields" (list "certSANs")
          "withExtraVolumes" true
          "root" $)
*/}}
{{- define "in-cloud-capi-template.patches.common.clusterConfigurationComponent" -}}
{{- $pathPrefix := .pathPrefix | default .component -}}
{{- $comp := index .root.Values.capi.k8s.controlPlane.components .component -}}
- selector:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta2
    kind: KubeadmControlPlaneTemplate
    matchResources:
      controlPlane: true

  jsonPatches:
{{- range .certSANsFields }}
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/clusterConfiguration/{{ $pathPrefix }}/{{ . }}
      valueFrom:
        template: |
          {{- with index $comp . }}
          {{- range $key, $value := . }}
          - {{ $value | quote }}
          {{- end }}
          {{- end }}
{{- end }}
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/clusterConfiguration/{{ $pathPrefix }}/extraArgs
      valueFrom:
        template: |
          {{- with $comp.extraArgs }}
          {{- range $key, $value := . }}
          - name: {{ $key }}
            value: {{ $value | quote }}
          {{- end }}
          {{- end }}
{{- if or .withExtraVolumes (not (hasKey . "withExtraVolumes")) }}
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/clusterConfiguration/{{ $pathPrefix }}/extraVolumes
      valueFrom:
        template: |
          {{- with $comp.extraVolumes }}
          {{- toYaml . | nindent 10 }}
          {{- end }}
{{- end }}
{{- end -}}

{{/*
Common patch: nodeRegistration (kubeletExtraArgs, advertiseAddress, imagePullPolicy).
Usage: include "...common.nodeRegistration"
  (dict "configuration"        "initConfiguration"
        "advertiseAddressPath" "/spec/template/spec/kubeadmConfigSpec/initConfiguration/localAPIEndpoint/advertiseAddress"
        "root" $)
*/}}
{{- define "in-cloud-capi-template.patches.common.nodeRegistration" -}}
- selector:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta2
    kind: KubeadmControlPlaneTemplate
    matchResources:
      controlPlane: true

  jsonPatches:
    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/{{ .configuration }}/nodeRegistration/kubeletExtraArgs
      valueFrom:
        template: |
          {{- with .root.Values.capi.k8s.controlPlane.components.kubelet.extraArgs }}
          {{- range $key, $value := . }}
          - name: {{ $key }}
            value: {{ $value | quote }}
          {{- end }}
          {{- end }}

    - op: add
      path: {{ .advertiseAddressPath }}
      value: "${ADVERTISE_ADDRESS}"

    - op: add
      path: /spec/template/spec/kubeadmConfigSpec/initConfiguration/nodeRegistration/imagePullPolicy
      value: IfNotPresent
{{- end -}}

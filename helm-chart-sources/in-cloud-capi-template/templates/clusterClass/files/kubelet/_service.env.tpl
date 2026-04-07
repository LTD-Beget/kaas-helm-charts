{{- define "in-cloud-capi-template.files.kubelet.service.args" -}}
- path: /etc/default/kubelet/extra-args.env
  owner: root:root
  permissions: '0644'
  content: |
    KUBELET_EXTRA_ARGS="--provider-id={{ $.Values.companyPrefix }}:///{{ "{{`{{ ds.meta_data.instance_id.split(':')[0] }}`}}" }}"
{{- end }}

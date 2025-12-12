{{- define "crossplane-functions.monitoring" -}}
{{- $securePort     := (default "11050"           .securePort) -}}
{{- $upstreamPort   := (default "8080"            .upstreamPort) -}}
{{- $secretName     := (default "secret-name"     .secretName) -}}

deploymentTemplate:
  spec:
    template:
      metadata:
        annotations:
          prometheus.io/path: /metrics
          prometheus.io/port: "{{ $upstreamPort }}"
          prometheus.io/scrape: "true"
      spec:
        containers:
          - name: rbac-proxy
            image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
            args:
              - --secure-listen-address=0.0.0.0:{{ $securePort }}
              - --upstream=http://127.0.0.1:{{ $upstreamPort }}
              - --tls-cert-file=/app/config/metrics/tls/tls.crt
              - --tls-private-key-file=/app/config/metrics/tls/tls.key
              - --v=2
            ports:
              - name: https-metrics
                containerPort: {{ $securePort }}
                protocol: TCP
            resources:
              requests:
                memory: "32Mi"
                cpu: "10m"
              limits:
                memory: "64Mi"
                cpu: "50m"
            volumeMounts:
              - name: rbac-proxy-tls
                mountPath: /app/config/metrics/tls
                readOnly: true
        volumes:
          - name: rbac-proxy-tls
            secret:
              defaultMode: 420
              secretName: "{{ $secretName }}"
{{- end -}}

{{- define "crossplane-functions.match-labels" -}}
{{- $kind := (default "Provider" .kind) -}}
{{- $name := (default "secret" .name) -}}
deploymentTemplate:
  spec:
    selector:
      matchLabels:
        pkg.crossplane.io/{{ $kind | lower }}: {{ $name }}
    template:
      metadata:
        labels:
          pkg.crossplane.io/{{ $kind | lower }}: {{ $name }}
{{- end -}}

{{- define "crossplane-functions.deep-merge" -}}
{{- $dict1 := index . 0 -}}
{{- $dict2 := index . 1 -}}
{{- $result := dict -}}

{{- range $key, $val := $dict1 -}}
  {{- $_ := set $result $key $val -}}
{{- end -}}

{{- range $key, $val2 := $dict2 -}}
  {{- $val1 := index $dict1 $key -}}
  {{- if and (kindIs "map" $val1) (kindIs "map" $val2) -}}
    {{- $merged := include "crossplane-functions.deep-merge" (list $val1 $val2) | fromYaml -}}
    {{- $_ := set $result $key $merged -}}
  {{- else if and (kindIs "slice" $val1) (kindIs "slice" $val2) -}}
    {{- $_ := set $result $key (append $val1 $val2) -}}
  {{- else -}}
    {{- $_ := set $result $key $val2 -}}
  {{- end -}}
{{- end -}}

{{- toYaml $result | nindent 0 -}}
{{- end -}}

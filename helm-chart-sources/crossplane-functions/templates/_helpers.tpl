{{- define "crossplane-functions.monitoring" -}}
{{- $securePort     := (default "11050"           .securePort) -}}
{{- $upstreamPort   := (default "8080"            .upstreamPort) -}}
{{- $secretName     := (default "secret-name"     .secretName) -}}

deploymentTemplate:
  spec:
    template:
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
{{- $kind := (default "secret" .kind) -}}
{{- $name := (default "secret" .name) -}}

selector:
  matchLabels:
    pkg.crossplane.io/{{ $kind | lower }}: {{ $name }}
{{- end -}}


{{- define "crossplane-functions.deep-merge-with-concat" -}}
  {{- $first := index . 0 -}}
  {{- $second := index . 1 -}}
  
  {{- if kindIs "map" $first and kindIs "map" $second -}}
    {{- $result := dict -}}
    
    {{- range $key, $value := $first -}}
      {{- if hasKey $second $key -}}
        {{- $mergedValue := include "crossplane-functions.deep-merge-with-concat" (list $value (get $second $key)) -}}
        {{- $result = set $result $key $mergedValue -}}
      {{- else -}}
        {{- $result = set $result $key $value -}}
      {{- end -}}
    {{- end -}}
    
    {{- range $key, $value := $second -}}
      {{- if not (hasKey $first $key) -}}
        {{- $result = set $result $key $value -}}
      {{- end -}}
    {{- end -}}
    
    {{- $result | toYaml -}}
  {{- else if kindIs "slice" $first and kindIs "slice" $second -}}
    {{- $result := concat $first $second -}}
    {{- $result | toYaml -}}
  {{- else -}}
    {{- $second | toYaml -}}
  {{- end -}}
{{- end -}}

{{- define "crossplane-functions.deep-merge-all-with-concat" -}}
  {{- $result := index . 0 -}}
  {{- range $index, $element := . -}}
    {{- if gt $index 0 -}}
      {{- $merged := include "crossplane-functions.deep-merge-with-concat" (list $result $element) | fromYaml -}}
      {{- $result = $merged -}}
    {{- end -}}
  {{- end -}}
  {{- $result | toYaml -}}
{{- end -}}

{{- define "inventory-access-gateway.name" -}}
simple-api
{{- end -}}

{{- define "inventory-access-gateway.fullname" -}}
{{ .Release.Name }}
{{- end -}}
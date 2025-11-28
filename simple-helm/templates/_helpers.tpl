{{- define "inventory-access-gateway.name" -}}
inventory-access-gateway
{{- end -}}

{{- define "inventory-access-gateway.fullname" -}}
{{ include "inventory-access-gateway.name" . }}-{{ .Release.Name }}
{{- end -}}

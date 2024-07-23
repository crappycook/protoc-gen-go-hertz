{{$svrType := .ServiceType}}
{{$svrName := .ServiceName}}

{{- range .MethodSets}}
const Operation{{$svrType}}{{.OriginalName}} = "/{{$svrName}}/{{.OriginalName}}"
{{- end}}

type HTTP{{.ServiceType}} interface {
{{- range .MethodSets}}
	{{- if ne .Comment ""}}
	{{.Comment}}
	{{- end}}
	{{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{- end}}
}

func RegisterHTTP{{.ServiceType}}(r *route.RouterGroup, srv HTTP{{.ServiceType}}) {
	{{- range .Methods}}
	r.{{.Method}}("{{.Path}}", _{{$svrType}}_{{.Name}}{{.Num}}_HTTP_Handler(srv))
	{{- end}}
}

{{range .Methods}}
func _{{$svrType}}_{{.Name}}{{.Num}}_HTTP_Handler(srv HTTP{{$svrType}}) func(c context.Context, ctx *app.RequestContext) {
	return func(c context.Context, ctx *app.RequestContext) {
		var in {{.Request}}
		if err := ctx.BindAndValidate(&in); err != nil {
			response.Fail(ctx, err)
			return
		}
		out, err := srv.{{.Name}}(c, &in)
		if err != nil {
			response.Fail(ctx, err)
			return
		}
		response.Success(ctx, out)
	}
}
{{end}}

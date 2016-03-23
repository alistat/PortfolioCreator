Promise = require("bluebird")

###
  renderFunctionExpr is a string with a javascript expression witch evaluates to a function
  It can simply be a function name
###
registerContentType = (name, renderFunctionExpr, description="") ->
  ContentType.findOne {name: name}
    .then (ct) ->
      if ct?
        null
      else
        ContentType.create {name: name, description: description, renderFunction: renderFunctionExpr}
          .then (val) -> val # identity function just to call exec and return promise


# BUILD IN ContentTypes

# Default page template
renderDefaultPage = (elem) ->
  pageSettings = if elem.content then JSON.parse(elem.content) else {title: ""}
  head = "<html><head><title>"+pageSettings.title+"</title></head><body>"
  foot = "</body></html>"
  Promise.reduce [Renderer.renderAndJoin(elem.children()), foot], ((text, s) -> text+s), head

registerContentType("Default Page", "ContentManagement.defaultPageRenderer")


module.exports =
  registerContentType: registerContentType
  defaultPageRenderer: renderDefaultPage

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

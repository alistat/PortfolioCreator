Promise = require("bluebird");

renderPage = (page) ->
  renderingActions = []
  for elem in page.elements
    renderingActions.push(renderElement(elem))
  Promise.all renderingActions
    .reduce ((html, elemHtml) -> html+elemHtml), ""


renderElement = (elem) ->
  eval(elem.type.renderFunction).call(elem.type, elem)

module.exports =
  renderPage: renderPage
  renderElement: renderElement

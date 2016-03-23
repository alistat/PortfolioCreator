Promise = require("bluebird")

renderPage = (page) ->
  renderAndJoin page.elements

renderElement = (elem) ->
  eval(elem.type.renderFunction).call(elem.type, elem)

renderAndJoin = (elems) ->
  Promise.all elems
    .map (elem) -> render(elem)
    .reduce ((html, elemHtml) -> html+elemHtml), ""

module.exports =
  renderPage: renderPage
  renderElement: renderElement
  renderAndJoin: renderAndJoin

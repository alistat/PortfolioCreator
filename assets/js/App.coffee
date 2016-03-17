App = {}

App.afterLibs = () ->
  $.fn.isEmpty = () ->
    return this.length == 0

ui = {}

ui.toggleTheButton = (elem, selectedHtml, unselectedHtml) ->
  jqThis = $(elem)
  console.log(jqThis.hasClass("selected"))
  if jqThis.hasClass "selected"
    jqThis.html(unselectedHtml).removeClass("btn-primary").addClass("btn-default").removeClass("selected");
  else
    jqThis.html(selectedHtml).addClass("btn-primary").removeClass("btn-default").addClass("selected");


validation = {}

validation.setFormValidation = (form) ->
  form = $(form)
  form.find('.required').each((i, elem) ->
    $(elem).data("validate", () ->
      console.log('hereeeeee')
      hasEror = not not this.hasError
      elemJQ = $(this)
      newHasError = not elemJQ.val()

      if hasEror != newHasError
        if newHasError
          elemJQ.parent().addClass "has-error"
        else
          elemJQ.parent().removeClass "has-error"
        this.hasError = newHasError
        if this.onValidationStateChange
          this.onValidationStateChange newHasError
    )
    $(elem).keyup((e) ->
      this.validate()
    )
  )

validation.validateForm = (form) ->
  form = $(form)
  form.find('.required').each((i, elem) ->
    elem.validate())

validation.formHasError = (form) ->
  validation.validateForm(form)
  return !$(form).find(".has-error").isEmpty()

validation.formToJSON = (form, elemName_elemSelectorAndGetter, targetObject) ->
  targetObject = {} if not targetObject?
  form = $(form)

  for prop, selectorAndTarget of elemName_elemSelectorAndGetter
    if selectorAndTarget instanceof Array
      selector = selectorAndTarget[0]
      getter = if selectorAndTarget.length > 1 then selectorAndTarget[1] else null
    else
      selector = selectorAndTarget

    if getter
      targetObject[prop] = getter(form.find(selector)[0])
    else
      targetObject[prop] = form.find(selector).val()
  targetObject

validation.jsonToForm = (json, elemName_elemSelectorAndSetter, targetForm) ->
  targetForm = $(targetForm)

  for prop, selectorAndTarget of elemName_elemSelectorAndSetter
    if selectorAndTarget instanceof Array
      selector = selectorAndTarget[0]
      setter = if selectorAndTarget.length > 1 then selectorAndTarget[1] else null
    else
      selector = selectorAndTarget

    if setter
      setter(targetForm.find(selector)[0], json[prop])
    else
      targetForm.find(selector).val(json[prop]);
  targetForm[0]

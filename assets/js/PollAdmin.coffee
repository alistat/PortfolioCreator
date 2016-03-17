PollAdmin = {}

PollAdmin.init = () ->
  optionViewToJSON = (view, option) ->
    return validation.formToJSON(view,
      {valueFirstPart: ".optionCatInput", valueSecondPart: ".optionNameInput", order: ".optionOrderInput"}, option)


  jsonToOptionView = (option, view) ->
    view = view ? view : $("#optionTempl").clone(true).removeAttr("id").css("display", "")
    return validation.jsonToForm(option, {
      valueFirstPart: ".optionCatInput", valueSecondPart: ".optionNameInput", order: ".optionOrderInput"}, view)


  groupViewToJSON = (view, group) -> validation.formToJSON(view, {name: ".groupNameInput"}, group)

  jsonToGroupView = (option, view) ->
    view = view ? view : $("#groupTempl").clone(true).removeAttr("id").css("display", "")
    validation.jsonToForm(option, {name: ".groupNameInput"}, view)


  optionsCount = (optList) ->
    optList = if optList then optList else $("#optionList")
    optList[0].children.length - 1


  onNewOption = () ->
    newOptionView = $('#newOption')
    opt = optionViewToJSON(newOptionView)
    opt.order = optionsCount()+1
    view = jsonToOptionView(opt)
    #view.validate()
    $("#optionList").append(view)
    jsonToOptionView({valueFirstPart: opt.valueFirstPart}, newOptionView)


  onNewGroup = () ->
    newGroupView = $('#newGroup')
    grp = groupViewToJSON(newGroupView)
    newGroupView.before(jsonToGroupView(grp))
    jsonToGroupView({}, newGroupView)


  optionSelectDeselect = (selectButton) ->
    ui.toggleTheButton(selectButton, '&#x2717;&nbsp;| <span class="selectHint">Επιλογή</span> #', '&#x2714;&nbsp;| <span class="selectHint">Επιλογή</span> #')
    jQButt = $(selectButton)
    if jQButt.hasClass('selected')
      jQButt.parents('.option').addClass('selected')
    else
      jQButt.parents('.option').removeClass('selected')


  onCopyValues = () ->
    optionList = $('#optionList')
    optCount = optionsCount(optionList)
    optionList.find(".option.selected").each (i, elem) ->
      opt = {valueSecondPart: optionViewToJSON(elem).valueSecondPart, order: ++optCount}
      optionList.append(jsonToOptionView(opt))



  onCopyCats = () ->
    optionList = $('#optionList')
    optCount = optionsCount(optionList)
    optionList.find(".option.selected").each (i, elem) ->
      opt = {valueFirstPart: optionViewToJSON(elem).valueFirstPart, order: ++optCount}
      optionList.append(jsonToOptionView(opt))


  onSetValues = () ->
    val = $(".optionValueMassInput").val()
    $('#optionList').find(".option.selected").each (i, elem) ->
      opt = PollAdmin.optionViewToJSON(elem)
      opt.valueSecondPart = val
      jsonToOptionView(opt, elem)

  onSetCats = () ->
    val = $(".optionCatMassInput").val()
    $('#optionList').find(".option.selected").each (i, elem) ->
      opt = optionViewToJSON(elem)
      opt.valueFirstPart = val
      jsonToOptionView(opt, elem)


  onSetValuesEnter = (e) -> onSetCats() if e.which == 13
  onSetCatsEnter = (e) -> onSetValues() if e.which == 13

  toListView = () ->
    $('#optionList').addClass('list')
    $(".option").find('.form-control').addClass('input-sm')


  toGridView = () ->
    $('#optionList').removeClass('list')
    $(".option").find('.form-control').removeClass('input-sm')


  PollAdmin.afterLibs = () ->
    App.afterLibs()

    $("#newOptionCat").datepicker(
      constrainInput: false
      dateFormat: "DD, d/m"
      showWeek: true
      firstDay: 0
      dayNames: ["Κυριακή", "Δευτερα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευη", "Σάββατο"]
      dayNamesMin: ["ΚΥ", "ΔΕ", "ΤΡ", "ΤΕ", "ΠΕ", "ΠΑ", "ΣΑ"]
      dayNamesShort: ["Κυρ", "Δευ", "Τρί", "Τετ", "Πέμ", "Παρ", "Σάβ"]
      showOn: "button"
    )
    $("#newOptionCat").parent().children(".ui-datepicker-trigger").remove()

    $(".optionSelectAll").click () ->
      $("#optionList").find(".option").not(".selected").each (i, elem) ->
        elem = $(elem)
        optionSelectDeselect(elem.find(".selectOption"))

    $(".optionInvertSelection").click () ->
      $("#optionList").find(".option").each (i, elem) ->
        elem = $(elem)
        optionSelectDeselect(elem.find(".selectOption"))

    $(".removeMass").click () -> $("#optionList").find(".selected").remove()

    $(".optionCatCalendar").click () -> $("#newOptionCat").datepicker("show")

    validation.setFormValidation("#forma, #optionTempl, #groupTempl")
    $("#newOptionBtn").click onNewOption
    $("#newOptionName, #newOptionCat").keypress (e) -> onNewOption() if e.which == 13

    $('#newOption').find('.validationIsSetUp').each (elem) ->
      elem.onValidationStateChange =  () ->
        $("#newOptionBtn").attr("enabled", validation.formHasError("#newOption")+"")

    $("#newGroupBtn").click onNewGroup
    $("#newGroupName").keypress (e) -> onNewGroup() if e.which == 13

    $('#newGroup').find('.validationIsSetUp').each (elem) ->
      elem.onValidationStateChange =  () ->
        $("#newGroupBtn").attr("enabled", validation.formHasError("#newGroup") + "")

(() ->

  extend = (object, properties) ->
    for own key, val of properties
      object[key] = val
    object

  arrayToOdjectSet = (arr) ->
    obj = {}
    obj[val] = true for val in arr
    obj

  ancestor =
    if typeof Element.prototype.closest is 'function'
    then (elem, selector) -> elem.closest(selector)
    else (elem, selector) -> par = jQuery(elem).parents(selector); if par.length > 0 then par[0] else null

  descendants =
    if typeof Element.prototype.querySelectorAll is 'function'
    then (elem, selector) -> elem.querySelectorAll(selector)
    else (elem, selector) -> jQuery(elem).find(selector)

  descendant =
    if typeof Element.prototype.querySelector is 'function'
    then (elem, selector) -> elem.querySelector(selector)
    else (elem, selector) -> des = jQuery(elem).find(selector); if des.length > 0 then des[0] else null

  val = (elem, val) ->
    if arguments.length > 1
      if elem.tagName.toUpperCase() == "IMG"
        elem.src = val
      else if elem.tagName.toUpperCase() == "A"
        elem.href = val
        elem.innerHTML = val
      else
        jQuery(elem).val(val)
    else
      if elem.tagName.toUpperCase() == "IMG"
        elem.src
      if elem.tagName.toUpperCase() == "A"
        elem.href
      else
        jQuery(elem).val()

  addListener = (elem, trigger, data, callback) ->
    console.log arguments
    jQuery(elem).on(trigger, null, data, callback)

  parse = (s) ->
    preprocessed = '{'
    marker = 0
    state = "IN_SPACE"

    automaton =
      IN_SPACE: (pos, char) ->
        if char == "'" then state = "IN_SINGLE_QUOTED"; preprocessed+='"'
        else if char == '"' then state = "IN_DOUBLE_QUOTED"; preprocessed+='"'
        else if /\w|[-.+]/.test(char) then state = "IN_UNQUOTED"; marker = pos
        else if /[:{}\[\],]/.test(char) then preprocessed+=char
        else if not /\s/.test(char) then throw "vf: unexpected character "+char+" at "+pos+" in "+s
      IN_DOUBLE_QUOTED: (pos, char) ->
        if char == '"' then state = "IN_SPACE"; preprocessed+='"'
        else if char == '\\' then state = "IN_ESCAPE_DOUBLE"; preprocessed+='\\'
        else  preprocessed+=char
      IN_SINGLE_QUOTED: (pos, char) ->
        if char == "'" then state = "IN_SPACE"; preprocessed+='"'
        else if char == '"' then preprocessed+='\\"'
        else if char == '\\' then state = "IN_ESCAPE_SINGLE"; preprocessed+='\\'
        else  preprocessed+=char
      IN_ESCAPE_DOUBLE: (pos, char) ->
        state = "IN_DOUBLE_QUOTED"; preprocessed+=char
      IN_ESCAPE_SINGLE: (pos, char) ->
        state = "IN_SINGLE_QUOTED"; preprocessed+=char
      IN_UNQUOTED: (pos, char) ->
        endOfInput = pos == s.length-1
        endOfToken = not /\w|[-.+]/.test(char)
        if endOfToken or endOfInput
          part = s.substring(marker, if not endOfToken then pos+1 else pos)
          if part != "true" and part != "false" and part != "null"  and not /^\d+(\.\d+)?([eE][+-]?\d+)?$/.test(part)
            preprocessed+= '"'+part+'"'
          else
            preprocessed+= part
          state = "IN_SPACE"
          if endOfToken
            automaton.IN_SPACE(pos, char)

    for i in [0..s.length-1]
      automaton[state](i, s.charAt(i))
    preprocessed+="}"

    try
      JSON.parse(preprocessed)
    catch err
      console.log 'vf: could not parse: '+ s
      throw err
  # end of parse

  clone = (elem, isDeep) ->
    jQuery(elem).clone(isDeep)[0]

  findParent = (elem, parentName, root) ->
    current = elem.parentNode
    while current? and current != root
      if current.vfModel? and (current.vfModel.object == parentName or current.vfModel.list == parentName)
        return current
      current = current.parentNode
    null


  initModel = (item) ->
    vfModel = parse(item.getAttribute "vf-model" )
    item.vfModel = vfModel
    if vfModel.atom?
      vfModel.val = if vfModel.getter? then eval(vfModel.getter).call(null, item) else val(item)
      vfModel.name = vfModel.atom
    if vfModel.object?
      vfModel.val = {}
      vfModel.name = vfModel.object
    if vfModel.list?
      vfModel.val = []
      vfModel.name = vfModel.list
    return vfModel

  getModel = (elem, model) ->
    rootName = elem.getAttribute("vf-model")
    rootName = if rootName? then parse(rootName) else null
    rootName = rootName?.object

    model ?= {}
    items = descendants(elem, "[vf-model]")

    for i in [0..items.length-1]
      item = items[i]
      vfModel = initModel(item)

      if vfModel.exclude then continue
      if (vfModel.parent? and vfModel.parent != rootName) or vfModel.ancestors?  or vfModel.ancestorsList?
        if vfModel.parent?
          parent = findParent(item, vfModel.parent, elem)
          if not parent? then throw "could not find parent "+vfModel.parent+" of "+vfModel.name
          parentIsList = parent.vfModel.list?
          parent = parent.vfModel.val
        else
          parentIsList = vfModel.ancestorsList?
          ancestorNames = vfModel.ancestors or vfModel.ancestorsList
          parent = model
          for ancestor, i in ancestorNames
            if parent[ancestor]?
              parent = parent[ancestor]
            else
              parent = parent[ancestor] = if parentIsList and i == ancestorNames.lenght-1 then [] else {}
        if parentIsList
          parent.push(vfModel.val)
        else
          if parent[vfModel.name]? then merge(vfModel.val, parent[vfModel.name])
          parent[vfModel.name] = vfModel.val
      else
        if model[vfModel.name]? then merge(vfModel.val, model[vfModel.name])
        model[vfModel.name] = vfModel.val
    model

  modelToTree = (model, treeRoot) ->
    if typeof model is "string" then return treeRoot
    treeRoot.children = {}
    for own key, value of model
      child = {parent: treeRoot, name: key, value: value}
      treeRoot.children[key] = child
      modelToTree(value, child)
    treeRoot

  setModel = (elem, model) ->
    rootName = elem.getAttribute("vf-model")
    rootName = if rootName? then parse(rootName) else null
    rootName = rootName?.object

    root = modelToTree(model, {name: rootName, value: model})
    tree = root
    items = descendants(elem, "[vf-model]")
    for i in [0..items.length-1]
      item = items[i]
      item.vfModel = vfModel = parse(item.getAttribute("vf-model"))
      vfModel.name = vfModel.list or vfModel.object or vfModel.atom

      if (vfModel.parent? and vfModel.parent != rootName) or vfModel.ancestors?  or vfModel.ancestorsList?
        if vfModel.parent?
          parent = tree
          while not not parent and parent.name != vfModel.parent
            parent = parent.parent
          if not parent then continue
          value = parent.value[vfModel.name]
        else
          ancestorNames = vfModel.ancestors or vfModel.ancestorsList
          parent = model
          for ancestor, i in ancestorNames
            parent = parent[ancestor]
            if not parent then break
          if not parent then continue
          value = parent[vfModel.name]
      else
        value = model[vfModel.name]

      if not vfModel.atom?
        if vfModel.parent?
          parent = findParent(item, vfModel.parent, elem)
          if parent?.vfModel.tree?
            vfModel.tree = tree = parent.vfModel.tree?.children[vfModel.name]
        else
          if root.children[vfModel.name]?
            vfModel.tree = tree = root.children[vfModel.name]
      else
        if typeof value != 'undefined'
          if vfModel.setter? then eval(vfModel.setter).call(null, item, value) else val(item, value)

  doCreate = (elem, createName) ->
    vfCreate = parse(elem.getAttribute "vf-create")
    template =  descendants(document, vfCreate.templ)
    template = clone(template, true)
    template.removeAttribute("id")
    template.style.display = ''
    model = getModel elem
    setModel template, model
    if vfCreate["append-to"]?
      descendant(document, vfCreate["append-to"]).appendChild(template)
    if vfCreate["insert-before"]?
      target = descendant(document, vfCreate["insert-before"])
      target.parentNode.insertBefore(template, target)
    if vfCreate["src-set-after"]?
      console.log vfCreate["src-set-after"]
      setModel elem, vfCreate["src-set-after"]
    if vfCreate["dest-set-after"]?
      setModel template, vfCreate["dest-set-after"]


  setUpListeners = (root) ->
    items = descendants(root, "[vf-listen]")
    if items.length is 0 then return
    for i in [0..items.length-1]
      item = items[i]
      vfListen = parse(item.getAttribute("vf-listen"))
      item.vfListen = vfListen
      if vfListen.action == "create"
        target = ancestor(item, "[vf-create]")
        addListener item, vfListen.on, target, (e) -> doCreate(e.data)


  document.addEventListener "DOMContentLoaded", () ->
    setUpListeners document


  checkBoxListGet = (elem) ->
    result = []
    checkboxes = descendants(elem, 'input[type="checkbox"]')
    for i in [0..checkboxes.length-1]
      elem = checkboxes[i]
      if elem.checked and elem.value? then result.push elem.value
    result

  checkBoxListSet = (elem, vals) ->
    vals = arrayToOdjectSet(vals)
    checkboxes = descendants(elem, 'input[type="checkbox"]')
    for i in [0..checkboxes.length-1]
      elem = checkboxes[i]
      elem.checked = vals[elem.value]


  checkBoxesGetBooleans = (elem) ->
    result = {}
    checkboxes = descendants(elem, 'input[type="checkbox"]')
    for i in [0..checkboxes.length-1]
      elem = checkboxes[i]
      result[elem.value] = elem.checked
    result


  checkBoxesSetBooleansUpdate = (elem, vals) ->
    checkboxes = descendants(elem, 'input[type="checkbox"]')
    for i in [0..checkboxes.length-1]
      elem = checkboxes[i]
      if vals[elem.value]? then elem.checked = vals[elem.value]

  checkBoxesSetBooleans = (elem, vals) ->
    checkboxes = descendants(elem, 'input[type="checkbox"]')
    for i in [0..checkboxes.length-1]
      elem = checkboxes[i]
      elem.checked =  not not vals[elem.value]


  fillSelectOptions = (elems, options) ->
    if not (elems instanceof Array) and not (elems instanceof NodeList) then elems = [elems]
    if options instanceof Array
      for i in [0..elems.length-1]
        for j in [0..options.length-1]
          elem = document.createElement("option"); elem.setAttribute("value", options[j]); elem.innerHTML = options[j];
          elems[i].appendChild elem;
    else
      for i in [0..elems.length-1]
        for own opt, optVal of options
          elem = document.createElement("option"); elem.setAttribute("value", opt); elem.innerHTML = optVal;
          elems[i].appendChild(elem);

  window.vf =
    getModel: getModel
    setModel: setModel
    doCreate: doCreate
    checkBoxListGet: checkBoxListGet
    checkBoxListSet: checkBoxListSet
    checkBoxesGetBooleans: checkBoxesGetBooleans
    checkBoxesSetBooleans: checkBoxesSetBooleans
    checkBoxesSetBooleansUpdate: checkBoxesSetBooleansUpdate
    fillSelectOptions: fillSelectOptions
)()

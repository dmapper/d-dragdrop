appendToBody = (el, component, stopPropagation) ->

  return if !el

  document.body.appendChild el

  return if el._hasDestroyListener or !component

  el._hasDestroyListener = true

  if stopPropagation
    component.dom.addListener el, 'click', (e) ->
      e.stopPropagation()

  component.on 'destroy', ->
    if el.parentNode
      return el.parentNode.removeChild(el)

module.exports =
  appendToBody: appendToBody

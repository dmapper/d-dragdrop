helper = require './helper'

module.exports = Draggable = (e, containerEl, handle, dragSelector, handleSelector, component, @moveCallback, startX, startY) ->
  items = containerEl.querySelectorAll dragSelector
  if dragSelector == handleSelector
    el = handle
  else
    handles = containerEl.querySelectorAll handleSelector
    index = nodeIndex handles, handle
    el = items[index]

  @el = el
  @container = cloneEl el
  @container.classList.add 'dragging'

  el.style.opacity = 0.5

  rect = el.getBoundingClientRect()
  startX ?= e.clientX
  startY ?= e.clientY
  @offsetLeft = rect.left - startX
  @offsetTop = rect.top - startY
  @onMove e
  helper.appendToBody @container, component
  return

Draggable::finish = (cancel) ->
  @el.style.opacity = ''
  unless cancel
    @moveCallback @el
  document.body.removeChild @container

Draggable::onMove = (e) ->
  @container.style.left = (e.clientX + window.pageXOffset + @offsetLeft) + 'px'
  @container.style.top = (e.clientY + window.pageYOffset + @offsetTop) + 'px'

nodeIndex = (nodeList, node) ->
  for child, i in nodeList
    return i if child == node
  return -1

cloneEl = (el) ->
  parent = el.parentNode

  # Need table if we are dragging something like a TR
  if parent.tagName == 'TBODY' || parent.tagName == 'THEAD'
    container = parent.parentNode.cloneNode false
    container.removeAttribute 'id'
    parentClone = parent.cloneNode false
    parentClone.removeAttribute 'id'
    container.appendChild parentClone
  else
    container = parentClone = parent.cloneNode false
    container.removeAttribute 'id'

  clone = el.cloneNode true
  clone.removeAttribute 'id'
  parentClone.appendChild clone

  container.style.width = window.getComputedStyle(parent).width
  container.style.position = 'absolute'
  clone.style = window.getComputedStyle el

  return container

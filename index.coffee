###*
 * Enables you to create a set of draggables tied to a set of droppables
 * When an item is being dragged, droppables will add class .hovered as the mouse moves over them
 * When an item is dropped into a droppabel target, a 'drop' event is emitted of form
 * (draggedItemEl, dropTargetEl)
 * Example:
 * <view name="droppable"
 *  container=".list-content" # The outer container that contains draggable items
 *  draggable="tr.profile" # Selector for draggable elements must be inside container
 *  droppable=".target" # Selector for droppable elements
 *  on-drop="viewFunction()">
###

Draggable = require './Draggable'

module.exports = class Droppable
  view: __dirname

  create: (model, dom) ->
    @_dragSelector = model.get('draggable') || '.draggable-item'
    @_handleSelector = model.get('handle') || @_dragSelector
    @_dropSelector = model.get('droppable') || '.droppable-target'
    @_containerSelector = model.get('container') || '.draggable-container'
    @_delayDistance = model.get('delay-distance') || 10

    @_droppables = document.querySelectorAll @_dropSelector
    @_container = document.querySelector @_containerSelector

    @_handle = null
    @_draggable = null
    @_dropTarget = null
    @_lastDown = null
    @_startPos = null

    @dom.on 'mousemove', (e) =>
      if @_startPos && @_handle && !@_draggable
        startX = @_startPos.clientX
        startY = @_startPos.clientY
        distanceX = e.clientX - startX
        distanceY = e.clientY - startY
        return if Math.sqrt(distanceX * distanceX + distanceY * distanceY) < @_delayDistance
        onDrop = (itemEl) =>
          return unless itemEl && @_dropTarget
          @emit 'drop', itemEl, @_dropTarget
        model.set 'dragging', true
        @_droppables = document.querySelectorAll @_dropSelector
        for droppable in @_droppables
          droppable.classList.add('droppable-target')
        @_draggable = new Draggable e, @_container, @_handle, @_dragSelector, @_handleSelector, this, onDrop, startX, startY

      return unless @_draggable
      @_draggable?.onMove e
      onMove e
    , true

    @dom.on 'mouseup', (e) =>
      @_startPos = null
      @_handle = null
      return unless @_draggable

      @finishDragging(false, e)

      # If the mouse is in the same spot as when down was fired, we click
      target = document.elementFromPoint(e.clientX, e.clientY)
      if @_lastDown == target
        @_lastDown.click()
    , true

    @dom.on 'blur', (e) =>
      @finishDragging(true)
    , true

    dom.on 'mousedown', @_down.bind(this), true

    onMove = (e) =>
      clientX = e.clientX
      clientY = e.clientY

      for droppable in @_droppables
        rect = droppable.getBoundingClientRect()

        if clientX > rect.left && clientX < rect.right
          if clientY > rect.top && clientY < rect.bottom
            @_dropTarget?.classList.remove('hovered')
            droppable.classList.add('hovered')
            @_dropTarget = droppable
            break

  finishDragging: (cancel, e) ->
    return unless @_draggable
    @emit e, @_draggable, @_dropTarget
    @_draggable.finish cancel

    @_handle = null
    @_draggable = null
    @_dropTarget = null
    @_lastDown = null
    @_startPos = null

    @model.set 'dragging', false

    # Clean up any hover states
    hovered = document.querySelectorAll @_dropSelector + '.hovered'
    for hover in hovered
      hover.classList.remove('hovered')
    # Remove the active class from all possible drop targets
    for droppable in @_droppables
      droppable.classList.remove('droppable-target')

  _down: (e) ->
    return if e.button != 0 # Left click only

    handle = containedBy @_container, e.target, @_handleSelector
    return unless handle   # Is what I'm clicking on in the container?

    @_handle = handle
    @_lastDown = el = e.target
    clientX = e.clientX
    clientY = e.clientY
    @_startPos = {clientX, clientY}

    # OPTIMIZE: This preventDefault is critical for some unknown performance reason, find out why
    e.preventDefault?()

containedBy = (root, target, selector) ->
  while target != root
    return target if target.matches? selector
    target = target.parentNode
    return unless target
  return

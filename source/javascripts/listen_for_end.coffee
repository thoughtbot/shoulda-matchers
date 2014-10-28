buildEventNames = (eventType) ->
  capitalizedEventType = eventType[0].toUpperCase() + eventType.slice(1)

  eventNames = [
    "#{eventType}end"
    "o#{capitalizedEventType}End"
    "webkit#{capitalizedEventType}End"
    "ms#{capitalizedEventType}End"
  ]

  eventNames.join(' ')

# Source: <http://stackoverflow.com/questions/11619341/detect-which-animationend-has-fired-via-animationname>
findEventId = (event, eventType) ->
  event["#{eventType}Name"] ? event.originalEvent["#{eventType}Name"]

$.fn.listenToEndOf = (eventType, expectedEventId, callback) ->
  eventNames = buildEventNames(eventType)

  @on eventNames, (event) ->
    actualEventId = findEventId(event, eventType)
    callback() if actualEventId == expectedEventId

$.fn.stopListeningToEndOf = (eventType) ->
  eventNames = buildEventNames(eventType)
  @off(eventNames)

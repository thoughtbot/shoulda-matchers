(function() {
  var buildEventNames, findEventId;

  buildEventNames = function(eventType) {
    var capitalizedEventType, eventNames;
    capitalizedEventType = eventType[0].toUpperCase() + eventType.slice(1);
    eventNames = ["" + eventType + "end", "o" + capitalizedEventType + "End", "webkit" + capitalizedEventType + "End", "ms" + capitalizedEventType + "End"];
    return eventNames.join(' ');
  };

  findEventId = function(event, eventType) {
    var _ref;
    return (_ref = event["" + eventType + "Name"]) != null ? _ref : event.originalEvent["" + eventType + "Name"];
  };

  $.fn.listenToEndOf = function(eventType, expectedEventId, callback) {
    var eventNames;
    eventNames = buildEventNames(eventType);
    return this.on(eventNames, function(event) {
      var actualEventId;
      actualEventId = findEventId(event, eventType);
      if (actualEventId === expectedEventId) {
        return callback();
      }
    });
  };

  $.fn.stopListeningToEndOf = function(eventType) {
    var eventNames;
    eventNames = buildEventNames(eventType);
    return this.off(eventNames);
  };

}).call(this);

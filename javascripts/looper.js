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
(function() {
  var findLastElementToFinishAnimating, loopAnimation, playAnimation, presentation, restartAnimation, restartAnimationWhenFinished, stopAnimation;

  presentation = [][0];

  stopAnimation = function() {
    return presentation.removeClass('running').addClass('paused');
  };

  playAnimation = function() {
    return presentation.addClass('running').removeClass('paused');
  };

  findLastElementToFinishAnimating = function() {
    return presentation.find('.animation-two');
  };

  restartAnimationWhenFinished = function() {
    return findLastElementToFinishAnimating().stopListeningToEndOf('animation').listenToEndOf('animation', 'fadeOut', restartAnimation);
  };

  restartAnimation = function() {
    stopAnimation();
    return setTimeout(loopAnimation, 1000);
  };

  loopAnimation = function() {
    playAnimation();
    return restartAnimationWhenFinished();
  };

  $(document).ready(function() {
    presentation = $('.presentation');
    return setTimeout(loopAnimation, 300);
  });

}).call(this);

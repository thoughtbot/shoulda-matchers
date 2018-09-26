window.StickyHeaders = (function ($) {
  var me = {},
      body, config, contentContainer, currentHeaderRangeIndex,
      currentScrollOffset, elem, headerRanges, headers, isScrolling,
      lastScrollOffset, selectors, stickyHeaderContainer;

  function init() {
    config = {
      switchOnCollisionWith: 'top',
      copy: 'element'
    };
    selectors = [];
    headers = [];
    headerRanges = [];

    currentHeaderRangeIndex = -1;
    currentScrollOffset = 0;
    lastScrollOffset = 0;
    isScrolling = false;

    createStickyHeader();
  }

  function createStickyHeader() {
    elem = $('<div>').attr('id', 'sticky-header');
  }

  function setHeaders() {
    var elements = [],
        stickyHeaderLineHeight = parseCssValue(elem.css('line-height')),
        stickyHeaderTopPadding;

    headers = [];
    $.each(selectors, function (_, selector) {
      contentContainer.find(selector).each(function (_, element) {
        var $element = $(element),
            fontSize = parseCssValue($element.css('font-size')),
            topOffset = (
              element.offsetTop +
              parseFloat($element.css('padding-top'), 10) +
              (- ((stickyHeaderLineHeight - fontSize) / 2))
            ),
            height = Math.round($element.height()),
            outerHeight = Math.round($element.outerHeight(true)),
            bottomOffset = topOffset + outerHeight;

        headers.push({
          element: element,
          $element: $element,
          topOffset: topOffset,
          bottomOffset: bottomOffset
        });
      })
    })
  }

  function setHeaderRanges() {
    var offsetProp = config.switchOnCollisionWith + 'Offset',
        start, end;

    headerRanges = [];
    for (var i = 0, len = headers.length; i < len; i++) {
      start = headers[i][offsetProp];

      if (headers[i+1]) {
        end = headers[i+1][offsetProp];
      } else {
        end = null;
      }

      headerRanges.push({
        start: start,
        end: end,
        element: headers[i].element
      });
    }

    //debugHeaderRanges();
  }

  function debugHeaderRanges() {
    contentContainer.find('.header-range-debug').remove();

    $.each(headerRanges, function (i, range) {
      var color = 'hsla('+(20*i)+', 100%, 50%, 0.15)',
          debug = $('<div>')
            .addClass('header-range-debug')
            .css({
              width: '100%',
              position: 'absolute',
              top: range.start + 'px',
              height: (range.end === null ? '1px' : (range.end - range.start) + 'px'),
              backgroundColor: color,
              borderTop: '1px solid black'
            })
            .appendTo(contentContainer)

      debug.append(
        $('<div>')
          .css({
            position: 'absolute',
            top: 0,
            right: 0,
            height: '2em',
            lineHeight: '2em',
            width: '40em',
            fontSize: '13px',
            backgroundColor: 'black',
            color: 'white',
            padding: '0 5px'
          })
          .text(headers[i].$element.text() + ' (#' + i + ')')
      )
    })
  }

  function setCurrentHeaderIndex() {
    var scrollTop = contentContainer.scrollTop();

    for (var i = 0, len = headers.length; i < len; i++) {
      if (scrollTop < headers[i].bottomOffset) {
        break;
      }
      currentHeaderIndex = i;
    }
  }

  function render() {
    var clonedHeader;

    if (currentHeaderRangeIndex < 0 || currentHeaderRangeIndex > headerRanges.length-1) {
      elem.removeClass('show');
      body.removeClass('has-sticky-header');
    }
    else {
      var realHeader = $(headerRanges[currentHeaderRangeIndex].element);

      if (typeof config.fillHeadersWith === 'function') {
        elem.html(config.fillHeadersWith(realHeader));
      } else if (config.fillHeadersWith === 'content') {
        elem.html(realHeader.clone().html());
      } else {
        elem.html(realHeader.clone());
      }

      elem.addClass('show');
      body.addClass('has-sticky-header');
    }

    return me;
  }

  function determineCurrentHeaderRangeIndex(startIndex, direction) {
    var index = startIndex;
    while (true) {
      currentHeaderRange = headerRanges[index];
      if (!currentHeaderRange || isWithinRange(currentScrollOffset, currentHeaderRange)) {
        break;
      } else {
        index += direction;
      }
    }
    return index;
  }

  function onScroll() {
    if (!headerRanges.length) {
      return;
    }

    currentScrollOffset = contentContainer.scrollTop();

    if (currentScrollOffset > headerRanges[0].start) {
      var newCurrentHeaderRangeIndex = currentHeaderRangeIndex;
      var currentHeaderRange = headerRanges[newCurrentHeaderRangeIndex];

      if (newCurrentHeaderRangeIndex < 0) {
        newCurrentHeaderRangeIndex = 0;
      }

      if (currentScrollOffset < lastScrollOffset) {
        // scrolling up
        newCurrentHeaderRangeIndex = determineCurrentHeaderRangeIndex(newCurrentHeaderRangeIndex, -1);
      } else {
        // scrolling down
        newCurrentHeaderRangeIndex = determineCurrentHeaderRangeIndex(newCurrentHeaderRangeIndex, +1);
      }
    } else {
      newCurrentHeaderRangeIndex = -1;
    }

    // only re-render when necessary
    if (newCurrentHeaderRangeIndex !== undefined && currentHeaderRangeIndex !== newCurrentHeaderRangeIndex) {
      currentHeaderRangeIndex = newCurrentHeaderRangeIndex;
      render();
    }

    lastScrollOffset = currentScrollOffset;
  }

  function listenToScroll(element, callback, options) {
    options = options || {};

    if (options.every) {
      element.on('scroll', function () {
        isScrolling = true;
      })

      setInterval(function () {
        if (isScrolling) {
          callback();
          isScrolling = false;
        }
      }, options.every);
    }
    else {
      element.on('scroll', callback);
    }
  }

  function isWithinRange(number, range) {
    return (
      number >= range.start &&
      (
        range.end === undefined ||
        range.end === null ||
        number <= range.end
      )
    );
  }

  function parseCssValue(value) {
    if (value === null || value === undefined) {
      return 0;
    } else {
      return parseInt(value, 10);
    }
  }

  me.setHeaders = setHeaders;
  me.setHeaderRanges = setHeaderRanges;

  me.set = function (/* key, value | config */) {
    if ($.isPlainObject(arguments[0])) {
      $.extend(config, arguments[0]);
    } else {
      config[arguments[0]] = arguments[1];
    }
    return me;
  }

  me.add = function (/* selectors... */) {
    selectors.push.apply(selectors, arguments);
    return me;
  }

  me.activate = function () {
    body = $('body');
    contentContainer = config.contentContainer ? $(config.contentContainer) : body;
    stickyHeaderContainer = config.stickyHeaderContainer ? $(config.stickyHeaderContainer) : contentContainer;

    stickyHeaderContainer.append(elem);
    setHeaders();
    setHeaderRanges();
    setCurrentHeaderIndex();

    return me;
  }

  me.update = function () {
    setHeaders();
    setHeaderRanges();
    render();

    listenToScroll(contentContainer, onScroll);
  }

  me.getHeaders = function () {
    return headers;
  }

  me.getHeaderRanges = function () {
    return headerRanges;
  }

  init();

  return me;
})(jQuery);

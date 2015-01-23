(function() {
  $(document).ready(function() {
    var animateElementsInView;
    if ($('.animate').length > 0) {
      animateElementsInView = function() {
        return $('.animate').each(function() {
          var element;
          element = $(this);
          if (element.visible(true, true)) {
            return element.addClass('animated');
          } else {
            return element.removeClass('animated');
          }
        });
      };
      animateElementsInView();
      return $(window).scroll(animateElementsInView);
    }
  });

}).call(this);

$(function() {
  var animate_icon;

  if ($(".animate").length > 0) {
    animate_icon = function() {
      return $(".animate").each(function(i, el) {
        var $el;
        $el = $(el);

        if ($el.visible(true, true)) {
          return $el.addClass("animated");
        } else {
          return $el.removeClass("animated");
        }
      });
    };

    animate_icon();

    return $(window).scroll(function(event) {
      return animate_icon();
    });
  }
});

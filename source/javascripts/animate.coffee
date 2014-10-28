$ ->
  if $('.animate').length > 0
    animate_icon = ->
      $('.animate').each (i, el) ->
        $el = $(el)
        if $el.visible(true, true)
          $el.addClass('animated')
        else
          $el.removeClass('animated')

    animate_icon()

    $(window).scroll (event) ->
      animate_icon()


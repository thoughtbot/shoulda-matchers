$(document).ready ->
  if $('.animate').length > 0
    animateElementsInView = ->
      $('.animate').each ->
        element = $(this)
        if element.visible(true, true)
          element.addClass('animated')
        else
          element.removeClass('animated')

    animateElementsInView()

    $(window).scroll(animateElementsInView)


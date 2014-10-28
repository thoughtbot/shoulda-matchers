#= require listen_for_end

[presentation] = []

stopAnimation = ->
  presentation.removeClass('running').addClass('paused')

playAnimation = ->
  presentation.addClass('running').removeClass('paused')

findLastElementToFinishAnimating = ->
  presentation.find('.animation-two')

restartAnimationWhenFinished = ->
  findLastElementToFinishAnimating()
    .stopListeningToEndOf('animation')
    .listenToEndOf('animation', 'fadeOut', restartAnimation)

restartAnimation = ->
  stopAnimation()
  setTimeout(loopAnimation, 1000)

loopAnimation = ->
  playAnimation()
  restartAnimationWhenFinished()

$(document).ready ->
  presentation = $('.presentation')
  setTimeout(loopAnimation, 300)

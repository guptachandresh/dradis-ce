//= require tylium/pages/boards/index
//= require tylium/pages/boards/show

document.addEventListener "turbolinks:load", ->
  if $('body.boards').length

    $('.js-board-modal').on 'click', (e)->
      e.preventDefault()
      $($(this).attr('href')).modal()

      false

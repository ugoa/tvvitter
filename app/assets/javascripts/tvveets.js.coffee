updateCountdown = ->
  remaining = 140 - jQuery("#tvveet_content").val().length
  jQuery(".countdown").text remaining

jQuery ->
  updateCountdown()
  $("#tvveet_content").change updateCountdown()
  $("#tvveet_content").keyup updateCountdown()
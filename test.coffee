
z = require './bind.coffee'
{task} = require 'proto-task-wait-done'

z.onconnect_a = ->
  
  z.send null, 'all_windows', (message) ->
    windows = message[0]
    windows.map (window_id) ->
      combine_titles = task.new()
      combine_titles.task = ->
        console.log @data

      combine_titles.wait 'title'
      z.send window_id, 'title', (message) ->
        title = message[0]
        combine_titles.done 'title', title
      
      combine_titles.wait 'app'
      z.send window_id, 'app', (message) ->
        app_id = message[0]
        z.send app_id, 'title', (message) ->
          app_title = message[0]
          combine_titles.done 'app', app_title

z.init port: 1235, ->
  z.send null, 'main_screen', (message) ->
    screen_id = message[0]
    console.log screen_id
    z.send screen_id, 'rotate_to', 90, ->

  z.send null, 'bind', 'e', ['cmd', 'alt'], ->
    console.log 'cmd alt e'

z = require './bind.coffee'
{task} = require 'proto-task-wait-done'

z.init port: 1235, ->

  z.all_windows (windows) ->
    windows.map (window_id) ->
      combine_titles = task.new()
      combine_titles.task = ->
        console.log @data

      combine_titles.wait 'title'
      z.send window_id, 'title', (title) ->
        combine_titles.done 'title', title
      
      combine_titles.wait 'app'
      z.send window_id, 'app', (app_id) ->
        z.send app_id, 'title', (app_title) ->
          combine_titles.done 'app', app_title

  z.send null, 'main_screen', (screen_id) ->
    console.log screen_id
    z.send screen_id, 'rotate_to', 90, ->

  z.send null, 'bind', 'e', ['cmd', 'alt'], ->
    console.log 'cmd alt e'

  z.bind 'l', ['cmd', 'alt'], ->
    # console.log '...'
    sizing = task.new()

    sizing.wait 'window_id'
    z.focused_window (window_id) ->
      # console.log 'window_id', window_id
      sizing.done 'window_id', window_id

    sizing.wait 'screen_size'
    z.main_screen (screen_id) ->
      z.send screen_id, 'frame_without_dock_or_menu', (frame) ->
        sizing.done 'screen_size', frame

    sizing.task = ->
      console.log @data
      frame =
        x: 0
        y: 0
        w: Math.round (@data.screen_size.w / 2)
        h: Math.round (@data.screen_size.h)
      z.send @data.window_id, 'set_frame', frame, ->
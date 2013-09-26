
z = require './bind.coffee'

z.connect port: 1235, ->

  z.all_windows (windows) ->
    # return
    windows.map (window_id) ->
      z.send window_id, 'title', (title) ->
        z.send window_id, 'app', (app_id) ->
          z.send app_id, 'title', (app_title) ->
            console.log title, app_title

  z.send null, 'bind', 'e', ['cmd', 'alt'], ->
    console.log 'cmd alt e'

  z.bind 'l', ['cmd', 'alt'], ->
    z.focused_window (window_id) ->
      z.main_screen (screen_id) ->
        z.send screen_id, 'frame_including_dock_and_menu', (frame) ->
          half_w = Math.round (frame.w / 2)
          half_h = Math.round (frame.h / 2)
          z.send window_id, 'set_frame',
            x: 0
            y: 0
            w: half_w
            h: frame.h
            ->

  z.bind 'r', ['cmd', 'alt'], ->
    z.focused_window (window_id) ->
      # console.log 'window_id', window_id
      z.main_screen (screen_id) ->
        z.send screen_id, 'frame_including_dock_and_menu', (frame) ->
          half_w = Math.round (frame.w / 2)
          half_h = Math.round (frame.h / 2)
          z.send window_id, 'set_frame',
            x: half_w
            y: 0
            w: half_w
            h: frame.h
            ->

  z.window_moved (window_id) ->
    console.log window_id
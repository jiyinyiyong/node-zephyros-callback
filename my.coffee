
z = require './bind.coffee'

do_in_screen = (callback) ->
  z.main_screen (screen_id) ->
    z.send screen_id, 'frame_including_dock_and_menu', (frame) ->
      {w, h} = frame
      round = Math.round
      rect =
        w: w
        w1: round (w / 6)
        w2: round (w / 3)
        w3: round (w / 2)
        w4: round (w / 3 * 2)
        w5: round (w / 6 * 5)
        h: h
        h1: round (h / 2)
      callback rect

new_frame = (x, y, w, h) ->
  {x, y, w, h}

divide_x = (key, x, y, w, h) ->
  z.bind key, ['ctrl', 'alt'], ->
    z.alert "ctrl alt #{key}", 0.3
    z.focused_window (window_id) ->
      frame = new_frame x, y, w, h
      z.send window_id, 'set_frame', frame

switch_window = ->
  z.bind 'tab', ["alt"], ->
    # z.alert "option tab ", 0.3
    z.focused_window (window_id) ->
      z.send window_id, "other_windows_on_same_screen", (ids) ->
        console.log window_id, "and", ids
        if ids[0]? and (typeof ids[0] is "number")
          z.send ids[0], "focus_window", ->
            # z.alert "end", 0.3
        else
          z.alert 'only window'

z.connect port: 1235, ->
  do_in_screen (rect) ->
    {w, w1, w2, w3, w4, w5, h, h1} = rect

    # windows of different widths, left to right
    divide_x 'h', 0, 0, w4, h
    divide_x 'j', 0, 0, w5, h
    divide_x 'k', w1, 0, w5, h
    divide_x 'l', w2, 0, w4, h

    # maximize a window
    divide_x 'i', 0, 0, w, h

  do switch_window
  z.alert "loaded My", 0.3


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

  z.alert "loaded My", 0.3

  z.listen 'window_created', (window_id) ->
    z.send window_id, 'app', (app_id) ->
      z.send app_id, 'title', (title) ->
        if title is 'Sublime Text'
          do_in_screen (rect) ->
            {w, w1, w2, w3, w4, w5, h, h1} = rect
            frame = new_frame w1, 0, w5, h
            z.send window_id, 'set_frame', frame

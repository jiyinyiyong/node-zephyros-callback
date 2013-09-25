
net = require 'net'

unit = (x) -> x + '\r\n'
str = (x) ->
  switch typeof x
    when 'object' then JSON.stringify x
    when 'string' then x
    else String x
delay = (t, f) -> setTimeout f, t

id =
  current: 0
  make: ->
    @current += 1
    @current

call = []

exports.init = (options, onconnect) ->

  client = net.connect options, onconnect

  exports.send = (receiver_id, method, args..., callback) ->
    msg_id = id.make()
    message = [msg_id, receiver_id, method, args...]
    # console.log 'message is', message
    client.write (unit (str message))
    unless message[2] in ['unbind', 'unlisten']
      call[msg_id] = {callback, message}

  client.on 'data', (message) ->
    message = message.toString()
    console.log message
    if message.indexOf('\n') >= 0
      message.split('\n').map handle_message
    else
      handle_message message

handle_message = (message) ->
  if message.toString().trim().length > 0
    [msg_id, value...] = JSON.parse message
    task = call[msg_id]
    if task?
      # console.log 'value:', value, task
      if task.message[2] in ['bind', 'listen']
        task.callback value... if task.ready?
        task.ready = yes
      else
        task.callback value...
        delete call[msg_id]
        # so 'bind' and 'listen' will be not be cleared
    else
      console.log 'no callback for', message.toString(), call

exports.api = (method, args..., callback) ->
  exports.send null, method, args..., callback

[ "bind", "unbind", "listen", "unlisten"
  "relaunch_config", "clipboard_contents"
  "focused_window", "visible_windows", "all_windows"
  "main_screen", "all_screens", "running_apps"
  "alert", "log", "show_box", "hide_box"
  "choose_from", "update_settings", "undo", "redo"
].map (method) ->
  exports[method] = (args..., callback) ->
    exports.api method, args..., callback

[ "window_created", "window_minimized", "window_unminimized"
  "window_moved", "window_resized"
  "app_launched", "focus_changed", "app_died", "app_hidden", "app_shown"
  "screens_changed", "mouse_moved", "modifiers_changed"
].map (method) ->
  exports[method] = (args..., callback) ->
    exports.listen method, args..., callback

[ "title", "set_frame", "set_top_left", "set_size", "frame", "top_left", "size"
  "maximize", "minimize", "un_minimize"
  "app", "screen"
  "focus_window"
  "focus_window_left", "focus_window_right", "focus_window_up", "focus_window_down"
  "windows_to_north", "windows_to_south", "windows_to_east", "windows_to_west"
  "normal_window?", "minimized?"
  "other_windows_on_same_screen", "other_windows_on_all_screens"
].map (method) ->

[ "visible_windows", "all_windows", "title"
  "hidden?", "show", "hide", "kill", "kill9"
].map (method) ->

[ "frame_including_dock_and_menu", "frame_without_dock_or_menu"
  "previous_screen", "next_screen", "rotate_to"
].map (method) ->

Node Zephyros Callback
------

Like node-zephyros, but simplified, and prefer callbacks then promise.

With [Zephros][Zephros], you are able to get window_ids, screen_ids, app_ids and talk ot listen to them. Mainly it is used to add key bindings for window resizing and moving.

Thie module is a thin wrapper on [Zephros's protocol][protocol]. It has language bindings in several languages, even one called [node-zephyros] wrapped with promise. You may find [more about the bindings in the repo][bindngs].

[Zephros]: https://github.com/sdegutis/zephyros
[protocol]: https://github.com/sdegutis/zephyros/blob/master/Docs/Protocol.md#events
[bindings]: https://github.com/sdegutis/zephyros/tree/master/Docs

### Usage

We got lots of callbacks:

```
npm install --save node-zephyros-callback
```

```coffee
z = require './bind.coffee'
{task} = require 'proto-task-wait-done'

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
```

### Guide

Before using this, you should read its [protocol][protocol] and have some basic ideas about using that.

`node-zephyros-callback` connects to Zephros with a TCP connection, which means you need to set Zephros to listen to a TCP port in its preference. The default port is `1235`, code it like this:

```coffee
z = require 'node-zephyros-callback'
z.connect port: 1235, ->
  # `z` is the entry
  # do stuffs after connection is established
```

Every message was consists of 4 parts like: `[msg_id, receiver_id, method, *args]`, 
`node-zephyros-callback` will take case of `msg_id` and make it into a callback,
so you don't have to write `msg_id`, but `receiver_id`s are required at times.

Basicly, `z.send` is for sending messages and attaching each with a callback, followed with a `window_id` -- the `receiver_id`, a `'title'` -- the `method`, some or zero `*args`, and an optional callback, like this demo:

```coffee
z.all_windows (windows) ->
  # return
  windows.map (window_id) ->
    z.send window_id, 'title', (title) ->
      z.send window_id, 'app', (app_id) ->
        z.send app_id, 'title', (app_title) ->
          console.log title, app_title
```

Top level APIs use `null` as `receiver_id`, so they are attached to `z` directly.
That why there's code like this:

```coffee
z.all_windows (windows) ->
  # `windows` is an array of `id`s, or exactly an array of numbers by now
```

Events are attached to `z` too, you may write like this:

```coffee
z.window_moved (window_id) ->
  console.log window_id
```

### More

Please read `test.coffee` and `my.coffee` for what I have now.
This module is not well tested, you may still find some problems.
If you find bugs, please report at issue or folk it, the code is short.

### License

BSD
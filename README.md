
Node Zephyros Callback
------

Like node-zephyros, but simplified, and prefer callbacks then promise.

### Usage

We got lots of callbacks:

```
npm install --save node-zephyros-callback
```

```coffee
z = require './bind.coffee'
{task} = require 'proto-task-wait-done'

z.init port: 1235, ->
  z.send null, 'main_screen', (message) ->
    screen_id = message[0]
    console.log screen_id
    z.send screen_id, 'rotate_to', 90, ->

  z.send null, 'bind', 'e', ['cmd', 'alt'], ->
    console.log 'cmd alt e'
```

### License

BSD
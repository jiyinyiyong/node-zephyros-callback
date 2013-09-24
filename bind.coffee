
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
    # console.log (typeof message), (JSON.stringify message)
    message = message.toString()
    if message.indexOf('\n') >= 0
      message.split('\n').map handle_message
    else
      handle_message message

handle_message = (message) ->
  if message.toString().trim().length > 0
    [msg_id, value...] = JSON.parse message
    task = call[msg_id]
    if task?
      task.callback value if task.ready?
      if task.message[2] in ['bind', 'listen']
        task.ready = yes
      else
        delete call[msg_id]
        # so 'bind' and 'listen' will be not be cleared
    else
      console.log 'no callback for', message.toString(), call
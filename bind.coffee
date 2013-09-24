
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

client = net.connect port: 1235, ->
  console.log 'connected'

exports.send = (receiver_id, method, args..., callback) ->
  msg_id = id.make()
  message = [msg_id, receiver_id, method, args...]
  console.log 'message is', message
  client.write (unit (str message))
  call[msg_id] = {callback, message}

client.on 'data', (message) ->
  [msg_id, value...] = JSON.parse message
  if call[msg_id]?
    call[msg_id].callback value
    unless call[msg_id].message[2] in ['bind', 'listen']
      delete call[msg_id]
  else
    console.log 'no callback for', message
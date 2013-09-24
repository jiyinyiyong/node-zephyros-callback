
z = require './bind'

z.send null, 'alert', 'demo', 2, ->
  console.log 'demo'
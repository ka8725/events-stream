require 'events'

keys = [nil, '42', '43']
names = ['created', 'updated', 'deleted']

loop do
  Events.connection.exec_params(
    "insert into events(name, payload, key) values ($1, $2, $3)", [names.sample, "test#{rand(10000)}", keys.sample]
  )
end

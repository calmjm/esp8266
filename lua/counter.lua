counter = 0
m = mqtt.Client("espcounter", 120)
t = require('ds18b20')

function trigger()
  counter = counter + 1
end

m:on("offline", function(con)
  print ("Offline")
  node.restart()
end)

m:on("message", function(conn, topic, data)
  if data ~= nil then
    print(topic .. " : " .. data)
  end
end)

m:connect("192.168.2.1", 1883, 0, 1,
  function(client)
    print("Connected to MQTT")
  end,
  function(client, reason)
    print("Failed to connect, reason: " .. reason)
    node.restart()
  end)

t.setup(DS_PIN)
addrs = t.addrs()
for i=1, table.getn(addrs) do print(t.read(addrs[i])) end

gpio.mode(INPUT_PIN, gpio.INT)
gpio.trig(INPUT_PIN, "up", trigger)
print("Startup done")

tmr.alarm(0, 60000, 1, function()
    print('Measuring..')
    output ="counter: " .. counter .. " "
    for i=1, table.getn(addrs) do
        output = output .. t.read(addrs[i]) .. " "
    end
    print(output)
    m:publish("msm", output, 2, 0, function(conn)
      print("sent")
    end)
end)

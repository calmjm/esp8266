IO_PIN = 3 -- gpio0
DS_PIN = 2 -- gpio4
state = 0
ws2812.init() -- gpio2

if adc.force_init_mode(adc.INIT_VDD33)
then
  node.restart()
  return
end
print("System voltage (mV):", adc.readvdd33())

t = require('ds18b20')
t.setup(DS_PIN)
addrs = t.addrs()
for i=1, table.getn(addrs) do print(t.read(addrs[i])) end

m = mqtt.Client("esp2", 120)
m:on("connect", function(con)
  print ("Connected")
  m:subscribe("trigger", 0, function(conn) print("trigger subscribe success") end)
  end)
m:on("offline", function(con)
  print ("Offline")
  node.restart()
end)

m:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if data ~= nil then
    if state == 0 then
      print("Switching ON")
      gpio.write(IO_PIN, gpio.HIGH)
      state = 1
    else
      print("Swithcing OFF")
      gpio.write(IO_PIN, gpio.LOW)
      state = 0
    end
  end
end)

m:connect("192.168.2.1", 1883, 0, 1, 
  function(client) 
    print("Connected to MQTT")
    m:subscribe("trigger", 0, function(conn) print("trigger subscribe success") end) 
  end, 
  function(client, reason) 
    print("Failed to connect, reason: " .. reason)
    node.restart()
  end)

tmr.alarm(0, 60000, 1, function()
    print('Measuring..')
    output ="esp3: "
    for i=1, table.getn(addrs) do
        output = output .. t.read(addrs[i]) .. " "
    end
    vcc = adc.readvdd33()
    rssi = wifi.sta.getrssi()
    output = output .. " " .. vcc .. " " .. rssi
    print(output)
    m:publish("mokkimittaukset", output, 2, 0, function(conn)
      print("sent")
    end)
end)

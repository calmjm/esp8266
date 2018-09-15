IO_PIN = 3 -- gpio0
DS_PIN = 2 -- gpio4
ws2812.init() -- gpio2
t = require('modds18b20')
state = 0
timer_round = 0
fade_round = 0
buffer = ws2812.newBuffer(15, 3)
buffer:fill(0, 0, 0)
ws2812.write(buffer)

function start_timer()
  for i=1, 15 do
    buffer:set(i, 100, 100, 100)
  end
  ws2812.write(buffer)
  tmr.alarm(1, 60000, tmr.ALARM_AUTO, function()
    print('ON timer round ' .. timer_round)
    for i=1, 15 do
      if i == timer_round then
        buffer:set(i, 0, 0, 0)
        ws2812.write(buffer)
      end
    end
    timer_round = timer_round + 1
    if timer_round == 16 then
      print("Swithcing OFF")
      gpio.write(IO_PIN, gpio.LOW)
      state = 0
      stop_timer()
    end
  end)
end

function stop_timer()
  tmr.unregister(1)
  fade_round = 0
  tmr.alarm(2, 50, tmr.ALARM_AUTO, function()
    buffer:fade(2)
    ws2812.write(buffer)
    fade_round = fade_round + 1
    if fade_round == 8 then
      tmr.unregister(2)
    end
  end)
end

if adc.force_init_mode(adc.INIT_VDD33)
then
  node.restart()
  return
end
print("System voltage (mV):", adc.readvdd33())

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
      timer_round = 1
      start_timer()
    else
      print("Swithcing OFF")
      gpio.write(IO_PIN, gpio.LOW)
      state = 0
      stop_timer()
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
    output = output .. " " .. vcc .. " " .. rssi .. " " .. state
    print(output)
    m:publish("mokkimittaukset", output, 2, 0, function(conn)
      print("sent")
    end)
end)

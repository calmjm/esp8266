ws2812.init()
ring = string.char(25, 0, 0)
ws2812.write(ring)

m = mqtt.Client("dualring", 120)
m:on("connect", function(con)
  print ("Connected")
  m:subscribe("rinkula",0, function(conn) print("rinkula subscribe success") end)
end)

m:on("offline", function(con)
  print("Offline, reconnecting in 10 s")
  tmr.alarm(0,10000,0, function() m:connect("172.25.0.1", 1883, 0) end)
end)

m:on("message", function(conn, topic, data)
  if data ~= nil then
    if topic == "rinkula" then
      ring = data
    end
    ws2812.write(ring)
  end
end)

m:connect("172.25.0.1", 1883, 0)

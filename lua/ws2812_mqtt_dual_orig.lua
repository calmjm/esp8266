ws2812.init(ws2812.MODE_DUAL)
ring = string.char(25, 0, 0)
bar = string.char(0, 25, 0)
ws2812.write(ring, bar)

m = mqtt.Client("dualespws", 120)
m:on("connect", function(con)
  print ("Connected")
  m:subscribe("lampos",0, function(conn) print("lampos subscribe success") end)
  tmr.alarm(0, 1000, 0, function ()
    m:subscribe("rinkula",0, function(conn) print("rinkula subscribe success") end)
  end)
end)

m:on("offline", function(con)
  m:connect("192.168.0.1", 1883, 0)
end)

m:on("message", function(conn, topic, data)
  if data ~= nil then
    if topic == "rinkula" then
      ring = data
    else
      bar = data
    end
    ws2812.write(ring, bar)
  end
end)

m:connect("192.168.0.1", 1883, 0)

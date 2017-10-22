m = mqtt.Client("lampoespws", 120)
m:on("connect", function(con)
  print ("Connected")
  m:subscribe("lampo",0, function(conn) print("subscribe success") end)
end)
m:on("offline", function(con) print ("Offline") end)
m:connect("192.168.0.1", 1883, 0)

m:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if data ~= nil then
    ws2812.write(4, data)
  end
end)

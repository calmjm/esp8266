m = mqtt.Client("dualespws", 120)
m:on("connect", function(con)
  print ("Connected")
  m:subscribe("lampos",0, function(conn) print("lampos subscribe success") end)
  tmr.alarm(0, 1000, 0, function ()
    m:subscribe("rinkula",0, function(conn) print("rinkula subscribe success") end)
  end)

end)
m:on("offline", function(con) print ("Offline") end)
m:connect("192.168.0.1", 1883, 0)

m:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if data ~= nil then
    if topic == "rinkula" then
      ws2812.write(4, data)
    else
      ws2812.write(3, data)
    end
  end
end)

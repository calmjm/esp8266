ws2812.init()
dht=require("dht")
status,temp,humi,temp_decimial,humi_decimial = dht.read(2)
print(temp)
print(humi)

m = mqtt.Client("esp4", 120)
m:on("connect", function(con)
  print ("Connected")
  m:subscribe("lampo",0, function(conn) print("subscribe success") end)
end)

m:on("offline", function(con)
  print ("Offline")
  node.restart() 
end)

m:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if data ~= nil then
    ws2812.write(data)
  end
end)

m:connect("192.168.0.1", 1883, 0)

tmr.alarm(0, 60000, 1, function() 
    print('Measuring..')
    output ="esp4: "
    status,temp,humi,temp_decimial,humi_decimial = dht.read(2)
    if ( status == dht.OK ) then
        output = output .. temp .. " " .. humi 
        print(output)
        m:publish("kasvarimittaukset", output, 2, 0, function(conn)
            print("sent")
        end)
    else
        print("Failed to read DHT22!")
    end
end)

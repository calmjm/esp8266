IO_PINS = {1, 2, 6, 7} -- gpio5, gpio4, gpio12, gpio13
DHT_PIN = 5 -- gpio14

dht=require("dht")
status, temp, humi, temp_decimial, humi_decimial = dht.read(DHT_PIN)
print(temp)
print(humi)

m = mqtt.Client("espsahko", 120)

m:on("message", function(conn, topic, data)
  if data ~= nil then
    print(topic .. ":" .. data)
    if string.len(data) == 4 then
      for i=1, 4 do
        if string.sub(data, i, i) == '1' then
          print("Switching " .. i .. " ON")
          gpio.write(IO_PINS[i], gpio.HIGH)
        else
          print("Swithcing ".. i .. " OFF")
          gpio.write(IO_PINS[i], gpio.LOW)
        end
      end
    else
      print("Invalid data received")
    end
  else
    print("Empty data received!")
  end
end)

m:connect("192.168.0.1", 1883, 0, 1, 
  function(client) 
    print("Connected to MQTT")
    m:subscribe("sahko-ohjaus", 0, function(conn) print("sahko-ohjaus subscribe success") end) 
  end, 
  function(client, reason) 
    print("Failed to connect, reason: " .. reason)
    node.restart()
  end)

m:on("offline", function(con)
  print ("Offline")
  node.restart()
end)

tmr.alarm(0, 60000, 1, function() 
    print('Measuring..')
    output ="espsahko: "
    status,temp,humi,temp_decimial,humi_decimial = dht.read(DHT_PIN)
    if ( status == dht.OK ) then
        output = output .. temp .. " " .. humi 
        print(output)
        m:publish("sahkomittaus", output, 2, 0, function(conn) 
            print("sent")
        end)
    else
        print("Failed to read DHT22!")
    end
end)

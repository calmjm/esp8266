
dht=require("dht")
status,temp,humi,temp_decimial,humi_decimial = dht.read(2)
print(temp)
print(humi)

mqtt = mqtt.Client("esp4", 120)
mqtt:on("connect", function(con) print ("Connected") end)
mqtt:on("offline", function(con) 
  print ("Offline")
  node.restart() 
end)
mqtt:connect("192.168.0.1", 1883, 0)

tmr.alarm(0, 60000, 1, function() 
    print('Measuring..')
    output ="esp4: "
    status,temp,humi,temp_decimial,humi_decimial = dht.read(2)
    if ( status == dht.OK ) then
        output = output .. temp .. " " .. humi 
        print(output)
        mqtt:publish("kasvarimittaukset", output, 2, 0, function(conn) 
            print("sent")
        end)
    else
        print("Failed to read DHT22!")
    end
end)

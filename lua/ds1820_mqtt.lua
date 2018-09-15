sda, scl = 5, 6 -- gpio012, gpio014
DHT_PIN = 2 -- gpio04
status,temp,humi,temp_decimial,humi_decimial = dht.read(DHT_PIN) -- gpio4
print(temp)
print(humi)

i2c.setup(0, sda, scl, i2c.SLOW)
bme280.setup()
print(bme280.read())

t = require('modds18b20')
t.setup(4) -- gpio2 
addrs = t.addrs()
for i=1, table.getn(addrs) do print(t.read(addrs[i])) end

mqtt = mqtt.Client("esp1", 120)
mqtt:on("connect", function(con) print ("Connected") end)
mqtt:on("offline", function(con) 
  print ("Offline")
  node.restart()
end)
mqtt:connect("192.168.0.1", 1883, 0)

tmr.alarm(0, 60000, 1, function() 
    print('Measuring..')
    output ="esp1: "
    for i=1, table.getn(addrs) do 
        output = output .. t.read(addrs[i]) .. " " 
    end
    status,temp,humi,temp_decimial,humi_decimial = dht.read(DHT_PIN)
    if ( status == dht.OK ) then
      output = output .. temp .. " " .. humi
    else
      output = output .. temp .. " U U"
    end
    T, P, H = bme280.read()
    output = output .. " " .. T/100 .. " " .. P/1000 .. " " .. H/1000
    print(output)
    mqtt:publish("mittaukset", output, 2, 0, function(conn) 
      print("sent") 
    end)
end)

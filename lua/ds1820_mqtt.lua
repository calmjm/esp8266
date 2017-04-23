
t = require('ds18b20')
t.setup(3)
addrs = t.addrs()
for i=1, table.getn(addrs) do print(t.read(addrs[i])) end

mqtt = mqtt.Client("esp1", 120)
mqtt:on("connect", function(con) print ("Connected") end)
mqtt:on("offline", function(con) print ("Offline") end)
mqtt:connect("192.168.0.1", 1883, 0)

tmr.alarm(0, 60000, 1, function() 
    print('Measuring..')
    output ="esp1: "
    for i=1, table.getn(addrs) do 
        output = output .. t.read(addrs[i]) .. " " 
    end
    print(output)
    mqtt:publish("mittaukset", output, 2, 0, function(conn) 
      print("sent") 
    end)
end)

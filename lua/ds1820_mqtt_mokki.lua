
t = require('ds18b20')
t.setup(4)
addrs = t.addrs()
for i=1, table.getn(addrs) do print(t.read(addrs[i])) end

mqtt = mqtt.Client("esp2", 120)
mqtt:on("connect", function(con) print ("Connected") end)
mqtt:on("offline", function(con)
  print ("Offline")
  node.restart()
end)
mqtt:connect("192.168.2.1", 1883, 0, 1, function(client) print("connected") end, 
                                     function(client, reason) print("failed reason: "..reason) end)

tmr.alarm(0, 60000, 1, function()
    print('Measuring..')
    output ="esp3: "
    for i=1, table.getn(addrs) do
        output = output .. t.read(addrs[i]) .. " "
    end
    print(output)
    mqtt:publish("mokkimittaukset", output, 2, 0, function(conn)
      print("sent")
    end)
end)

ABORT_PIN = 5 -- gpio14
DS_PIN = 4 -- gpio2

t = require('ds18b20')
t.setup(DS_PIN)
addrs = t.addrs()
for i=1, table.getn(addrs) do print(t.read(addrs[i])) end


function startup()
    counter = 0
    -- wifi.sta.setip({ip="192.168.2.14", netmask="255.255.255.0", gateway="192.168.2.1"})
    uart.setup(0, 9600, 8, 0, 1, 1)
    gpio.mode(ABORT_PIN, gpio.INPUT, gpio.PULLUP)
    if gpio.read(ABORT_PIN) == 0 then
        print('Start aborted!')
        return
        end
    print('Start.')
    tmr.alarm(1, 300, 1, function()
        if wifi.sta.getip() == nil then
            print("Waiting for IP address...")
            counter = counter + 1
            if counter > 30 then
                tmr.stop(1)
                print("Failed to get IP address!")
                node.dsleep(60 * 1000000)
            end 
        else
            print("IP address is " .. wifi.sta.getip())
            tmr.stop(1)
            remote_control()
        end
    end)
    end

function remote_control()
    print('Creating MQTT client')
    m = mqtt.Client("kompostiesp", 120)
    print('Registering connect')
    m:on("connect", function(con) 
        print ("Connected")
        output ="kompostiesp: "
        for i=1, table.getn(addrs) do 
            output = output .. t.read(addrs[i]) .. " " 
        end
        print(output)
        m:publish("komposti", output, 2, 0, function(conn)
            print("Sent")
            tmr.alarm(1, 100, 0, function()
                print("Sleeping...")
                node.dsleep(60 * 1000000)
            end)
        end)
    end)
    print('Registering offline')
    m:on("offline", function(con) 
      print ("Offline")
      -- node.restart() 
    end)
    print('Connecting...')
    m:connect("192.168.0.1", 1883, 0)
    print('Finished initialization')
    end

startup()

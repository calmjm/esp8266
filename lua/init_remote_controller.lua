ABORT_PIN = 5 -- gpio14
LED_PIN = 3 -- gpio0

function startup()
    wifi.sta.setip({ip="192.168.0.13", netmask="255.255.255.0", gateway="192.168.0.1"})
    uart.setup(0, 9600, 8, 0, 1, 1)
    gpio.mode(ABORT_PIN, gpio.INPUT, gpio.PULLUP)
    gpio.mode(LED_PIN, gpio.OUTPUT)
    gpio.write(LED_PIN, gpio.LOW)
    if gpio.read(ABORT_PIN) == 0 then
        print('Start aborted!')
        return
        end
    print('Start.')
    tmr.alarm(1, 100, 1, function()
        if wifi.sta.getip() == nil then
            print("Waiting for IP address...")
        else
            print("IP address is " .. wifi.sta.getip())
            tmr.stop(1)
            remote_control()
        end
    end)
    end

function remote_control()
    print('Creating MQTT client')
    m = mqtt.Client("esp5", 120)
    print('Registering connect function')
    m:on("connect", function(con)
        print ("Connected")
        m:publish("trigger", '1', 2, 0, function(conn)
            gpio.write(LED_PIN, gpio.HIGH)
            print("Trigger sent")
            tmr.alarm(1, 100, 1, function()
                gpio.write(LED_PIN, gpio.LOW) 
                node.dsleep(0) 
            end)
        end)
    end)
    m:on("offline", function(con)
      print ("Offline")
      node.restart() 
    end)
    print('Connecting...')
    m:connect("192.168.0.1", 1883, 0)
    print('Finished initialization')
    end

startup()

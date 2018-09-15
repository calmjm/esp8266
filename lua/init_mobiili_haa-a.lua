ABORT_PIN = 5 -- gpio14
D_PIN = 4 -- gpio2
t = require('modds18b20')

t.setup(D_PIN)
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
    if adc.force_init_mode(adc.INIT_VDD33)
    then
        node.restart()
        return
    end
    vcc = adc.readvdd33(0)
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
    -- status,temp,humi,temp_decimial,humi_decimial = dht.read(D_PIN)
    temp = t.read(addrs[1])
    if ( temp ~= 85 ) then
        humi = 0
        R = wifi.sta.getrssi()
        output = "temp=" .. temp .. "&humi=" .. humi .. "&vcc=" .. vcc .. "&rssi=" .. R
        print(output)
        http.post("http://172.25.0.1/m.php?a=1", "Content-type: application/x-www-form-urlencoded\r\n", output, 
            function(status_code, body, headers)
                if ( status_code == -1) then
                    print("Failed")
                else
                    print("Sent")
                end
                tmr.alarm(1, 100, 0, function()
                    print("Sleeping...")
                    node.dsleep(60 * 1000000)
            end)
        end)
    end
end

startup()

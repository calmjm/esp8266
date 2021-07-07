ABORT_PIN = 2 -- gpio14
sda, scl = 6, 7 -- gpio012, gpio013

i2c.setup(0, sda, scl, i2c.SLOW)
bme280.setup()

P, T = bme280.baro()
print(P)
print(T)

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
  P, T = bme280.baro()
  output = "temp=" .. T/100 .. "&pressure=" .. P/1000 .. "&vcc=" .. vcc
  print(output)
  http.post("http://api.t-ocdn.com/ulkopaine", "Content-type: application/x-www-form-urlencoded\r\n", output, 
    function(status_code, body, headers)
      if ( status_code == -1) then
        print("Failed")
      else
        print("Sent")
      end
      print("Waiting...")
      tmr.alarm(1, 60 * 1000, 0, remote_control)
    end)
end

startup()

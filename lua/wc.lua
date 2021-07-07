PIR_PIN = 6 -- gpio12
SW_PIN = 7 -- gpio13
ABORT_PIN = 2 -- gpio04
CHIPID = node.chipid()
counter = 0

function communicate(output)
  http.post("http://api.t-ocdn.com/esp-kikkare", "Content-type: application/x-www-form-urlencoded\r\n", output,
    function(status_code, body, headers)
      if ( status_code == -1) then
        print("Failed")
      else
        print("Sent")
      end
  end)
end

function startup()
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
            output = "start=1&node=" .. CHIPID
            communicate(output)
        end
    end)
end

function trigger_pir()
  print("Movement detected!")
  if closed == true and occupied == false then
    print("Occupied!")
    occupied = true
    output = "occupied=1&node=" .. CHIPID
    communicate(output)
  end
end

function trigger_switch()
  state = gpio.read(SW_PIN)
  print("Switch triggered to " .. state)
  if state == gpio.HIGH then
    closed = false
  else
    closed = true
  end
  if closed == false and occupied == true then
    print("Freed")
    occupied = false
    output = "occupied=0&node=" .. CHIPID
    communicate(output)
  end
end

gpio.mode(PIR_PIN, gpio.INPUT)
gpio.mode(SW_PIN, gpio.INPUT, gpio.PULLUP)
gpio.mode(ABORT_PIN, gpio.INPUT, gpio.PULLUP)
gpio.trig(PIR_PIN, "up", trigger_pir)
gpio.trig(SW_PIN, "both", trigger_switch)

uart.setup(0, 9600, 8, 0, 1, 1)
closed = false
occupied = false
startup()

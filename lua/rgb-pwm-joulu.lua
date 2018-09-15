RED = 6
GREEN = 5 
BLUE = 7
FREQ = 1000
red_value = 150
green_value = 55
blue_value = 25
mode = "0" -- 0 = trigger from pin, 1 = always on
lit_time = 60
trigger_on = 0
m = mqtt.Client("esppwmjoulu", 120)

function split(input)
  local arr={}; i = 1
  arr[4] = "0"
  arr[5] = lit_time
  for str in string.gmatch(input, "%S+") do
    arr[i] = str
    i = i + 1
  end
  return arr[1], arr[2], arr[3], arr[4], arr[5]
end

function led(r, g, b)
  pwm.setduty(RED, r)
  pwm.setduty(GREEN, g)
  pwm.setduty(BLUE, b)
end


function trigger_change()
  local rv = pwm.getduty(RED)
  local gv = pwm.getduty(GREEN)
  local bv = pwm.getduty(BLUE)
  local rs = (red_value-rv)/200
  local gs = (green_value-gv)/200
  local bs = (blue_value-bv)/200
  print("Setting leds to new state")
  for i=1, 200 do
    rv = rv + rs
    gv = gv + gs
    bv = bv + bs
    led(rv, gv, bv)
    tmr.delay(10)
  end
  tmr.alarm(0, lit_time * 1000, 0, trigger_change)
end

m:on("offline", function(con)
  print ("Offline")
  node.restart()
end)

m:on("message", function(conn, topic, data)
  print(topic .. " : " .. data)
  if data ~= nil then
    red_value, green_value, blue_value, mode, lit_time = split(data)
    if mode == "1" then
      led(red_value, green_value, blue_value)
    end
  end
end)

m:connect("192.168.0.1", 1883, 0, 1,
  function(client)
    print("Connected to MQTT")
    m:subscribe("joulupwm", 0, function(conn) print("joulupwm subscribe success") end)
  end,
  function(client, reason)
    print("Failed to connect, reason: " .. reason)
    node.restart()
  end)

pwm.setup(RED, FREQ, 0)
pwm.setup(GREEN, FREQ, 0)
pwm.setup(BLUE, FREQ, 0)
led(10, 10, 10)
print("Startup done")
trigger_change()

RED = 6
GREEN = 5 
BLUE = 7
FREQ = 1000
red_value = 150
green_value = 55
blue_value = 25
mode = "0" -- 0 = trigger from pin, 1 = always on
lit_time = 120
trigger_on = 0
m = mqtt.Client("esppwm", 120)

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

function trigger_down()
  local rs = red_value/100
  local gs = green_value/100
  local bs = blue_value/100
  local rv = red_value
  local gv = green_value
  local bv = blue_value
  print("Setting leds off")
  for i=1,100 do 
    rv = rv - rs
    gv = gv - gs
    bv = bv - bs
    led(rv, gv, bv)
    tmr.delay(10)
  end
  trigger_on = 0
end

function trigger_up()
  local rs = red_value/100
  local gs = green_value/100
  local bs = blue_value/100
  local rv = 0
  local gv = 0
  local bv = 0
  m:publish("kaytava_pir", "1", 2, 0, function(conn)
    print("Movement detected!")
  end)
  if mode == "0" then
    tmr.alarm(0, lit_time * 1000, 0, trigger_down)
  end
  if mode == "0" and trigger_on == 0 then
    trigger_on = 1
    print("Setting leds on")
    for i=1, 100 do
      rv = rv + rs
      gv = gv + gs
      bv = bv + bs
      led(rv, gv, bv)
      tmr.delay(10)
    end
  end
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
    m:subscribe("kaytavapwm", 0, function(conn) print("kaytavapwm subscribe success") end)
  end,
  function(client, reason)
    print("Failed to connect, reason: " .. reason)
    node.restart()
  end)

gpio.mode(INPUT_PIN, gpio.INT)
gpio.trig(INPUT_PIN, "up", trigger_up)
pwm.setup(RED, FREQ, 0)
pwm.setup(GREEN, FREQ, 0)
pwm.setup(BLUE, FREQ, 0)
led(0, 0, 0)
print("Startup done")

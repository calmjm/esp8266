PWM_PINS = {2, 6, 7} -- gpio4, gpio13, gpio14
INPUT_PIN = 5 -- gpio12
POWER_PIN = 1 -- gpio5

function shutdown()
  print("Stop.")
  pwm.setduty(PWM_PINS[1], 110)
  for i=1, 8000 do
    tmr.delay(100)
  end
  gpio.write(POWER_PIN, gpio.LOW)
end

function startup()
    if abort == true then
        print('Start aborted!')
        return
    end
    print('Start.')
    pwm.setduty(PWM_PINS[1], 28)
    tmr.alarm(0,5000,0,shutdown)    
end

uart.setup(0, 9600, 8, 0, 1, 1)	

gpio.mode(POWER_PIN, gpio.OUTPUT)
gpio.write(POWER_PIN, gpio.HIGH)
gpio.mode(INPUT_PIN, gpio.INPUT)
for i=1, 3 do
    gpio.mode(PWM_PINS[i], gpio.OUTPUT)
    gpio.write(PWM_PINS[i], gpio.LOW)
end
pwm.setup(PWM_PINS[1],50,85)
pwm.setduty(PWM_PINS[1], 110)

abort = false
tmr.alarm(0,10000,0,startup)

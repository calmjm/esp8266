PWM_PINS = {5, 6, 7} -- gpio12, gpio13, gpio14
INPUT_PIN = 2 -- gpio04

function startup()
    if abort == true then
        print('Start aborted!')
        return
    end
    print('Start.')
    dofile('rgb-pwm.lua')
end

uart.setup(0, 9600, 8, 0, 1, 1)	

gpio.mode(INPUT_PIN, gpio.INPUT)
for i=1, 3 do
    gpio.mode(PWM_PINS[i], gpio.OUTPUT)
    gpio.write(PWM_PINS[i], gpio.LOW)
end

abort = false
tmr.alarm(0,10000,0,startup)

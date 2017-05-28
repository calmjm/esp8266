IO_PIN = 3 -- gpio0

function startup()
    gpio.mode(IO_PIN, gpio.OUTPUT)
    gpio.write(IO_PIN, gpio.LOW)
    if abort == true then
        print('Start aborted!')
        return
        end
    print('Start.')
    dofile('ds1820_mqtt_mokki.lua')
    end

uart.setup(0, 9600, 8, 0, 1, 1)
abort = false
tmr.alarm(0,10000,0,startup)

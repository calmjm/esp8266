IO_PIN = 3 -- gpio0

function startup()
    if abort == true then
        print('Start aborted!')
        return
        end
    print('Start.')
    dofile('telnet.lua')
    dofile('ds1820_mqtt_mokki.lua')
    end

gpio.mode(IO_PIN, gpio.OUTPUT)
gpio.write(IO_PIN, gpio.LOW)
uart.setup(0, 9600, 8, 0, 1, 1)	
abort = false
tmr.alarm(0,10000,0,startup)

function startup()
    if abort == true then
        print('Start aborted!')
        return
        end
    print('Start.')
    dofile('ds1820_mqtt_mokki.lua')
    end

abort = false
uart.setup(0, 9600, 8, 0, 1, 1)
tmr.alarm(0,10000,0,startup)

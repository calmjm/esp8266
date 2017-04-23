function startup()
    if abort == true then
        print('Start aborted!')
        return
        end
    print('Start.')
    dofile('ws2812_mqtt.lua')
    end

abort = false
tmr.alarm(0,10000,0,startup)

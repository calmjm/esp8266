function startup()
    if abort == true then
        print('Start aborted!')
        return
        end
    print('Start.')
    dofile('ds1820_mqtt_kasvari.lua')
    end

abort = false
tmr.alarm(0,10000,0,startup)

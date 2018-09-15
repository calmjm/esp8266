function startup()
    if abort == true then
        print('Start aborted!')
        return
    end
    print('Start.')
--    dofile('counter.lua')
end

uart.setup(0, 9600, 8, 0, 1, 1)	

abort = false
tmr.alarm(0,10000,0,startup)

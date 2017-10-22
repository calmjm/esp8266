INPUT_PIN = 2 -- gpio04
DS_PIN = 4 -- gpio02

function startup()
    if abort == true then
        print('Start aborted!')
        return
    end
    print('Start.')
    dofile('counter.lua')
end

uart.setup(0, 9600, 8, 0, 1, 1)	
gpio.mode(INPUT_PIN, gpio.INPUT)

abort = false
tmr.alarm(0,10000,0,startup)

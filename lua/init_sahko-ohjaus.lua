IO_PINS = {1, 2, 6, 7} -- gpio5, gpio4, gpio12, gpio13

function startup()
    if abort == true then
        print('Start aborted!')
        return
        end
    print('Start.')
    dofile('sahko-ohjaus.lua')
    end

uart.setup(0, 9600, 8, 0, 1, 1)	

for i=1, 4 do
    gpio.mode(IO_PINS[i], gpio.OUTPUT)
    gpio.write(IO_PINS[i], gpio.LOW)
end

abort = false
tmr.alarm(0,10000,0,startup)

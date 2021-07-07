SDA_PIN = 6 -- sda pin, GPIO12
SCL_PIN = 5 -- scl pin, GPIO14
bh1750 = require("bh1750")
bh1750.init(SDA_PIN, SCL_PIN)

tmr.alarm(0, 1000, 1, function()
    l = bh1750.read_lux()
    print("lux: " .. l)
end)

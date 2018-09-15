alt=17 -- altitude of the measurement place

sda, scl = 1, 2
i2c.setup(0, sda, scl, i2c.SLOW) -- call i2c.setup() only once
print(bme280.setup())
print(bme280.read())
print(bme280.humi())

T, P, H, QNH = bme280.read(alt)
local Tsgn = (T < 0 and -1 or 1); T = Tsgn*T
print(string.format("T=%s%d.%02d", Tsgn<0 and "-" or "", T/100, T%100))
print(string.format("QFE=%d.%03d", P/1000, P%1000))
print(string.format("QNH=%d.%03d", QNH/1000, QNH%1000))
print(string.format("humidity=%d.%03d%%", H/1000, H%1000))
D = bme280.dewpoint(H, T)
local Dsgn = (D < 0 and -1 or 1); D = Dsgn*D
print(string.format("dew_point=%s%d.%02d", Dsgn<0 and "-" or "", D/100, D%100))

-- altimeter function - calculate altitude based on current sea level pressure (QNH) and measure pressure
P = bme280.baro()
curAlt = bme280.altitude(P, QNH)
local curAltsgn = (curAlt < 0 and -1 or 1); curAlt = curAltsgn*curAlt
print(string.format("altitude=%s%d.%02d", curAltsgn<0 and "-" or "", curAlt/100, curAlt%100))

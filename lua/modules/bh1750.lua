local M = {}
local ADDR = 0x23 -- Addr L
local COMMAND = 0x20 -- One time H-resolution mode
local i2c = i2c
local ID = 0 -- Always sero

function M.init(sda, scl)
  i2c.setup(ID, sda, scl, i2c.SLOW)
end

local function read_data_from_bh1750(address)
  i2c.start(ID)
  i2c.address(ID, address, i2c.TRANSMITTER)
  i2c.write(ID, COMMAND)
  i2c.stop(ID)
  i2c.start(ID)
  i2c.address(ID, address,i2c.RECEIVER)
  tmr.delay(185000) -- Wait to complete H-resolution mode measurement max. 180 ms
  data = i2c.read(ID, 2)
  i2c.stop(ID)
  return data
end

function M.read_lux()
  data_string = read_data_from_bh1750(ADDR)
  data = data_string:byte(1) * 256 + data_string:byte(2)
  lux = (data / 1.2) -- H-reslution mode : Illuminance per 1 count ( lx / count ) = 1 / 1.2
  return(lux)
end

return M

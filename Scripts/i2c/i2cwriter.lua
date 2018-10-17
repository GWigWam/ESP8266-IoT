local i2cAdr = 0x00;

local function init(sda, scl, adr)
    i2cAdr = adr;
    i2c.setup(0, sda, scl, i2c.SLOW)
end

local function w(data)
    i2c.start(0)
    i2c.address(0, i2cAdr, i2c.TRANSMITTER)
    w = i2c.write(0, data)
    i2c.stop(0)
end

print("'i2cwriter.lua'")
return {
    init = init,
    w = w
}

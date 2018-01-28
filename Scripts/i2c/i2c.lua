print "'i2c.lua'"

sda = 2
scl = 1
adr = 0x3F
i2cdebug = true
i2c.setup(0, sda, scl, i2c.SLOW)

function i2cw(data)
    i2c.start(0)
    i2c.address(0, adr, i2c.TRANSMITTER)
    w = i2c.write(0, data)
    i2c.stop(0)

    if i2cdebug then
        debstr = string.format("i2c (%i):", w)
        for i = 1, #data do    
            debstr = string.format("%s 0x%02X |", debstr, data[i])
        end
        print(debstr)
    end
end

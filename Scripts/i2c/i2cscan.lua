sda = 2
scl = 1

function find_dev(i2c_id, dev_addr)
     i2c.start(i2c_id)
     c=i2c.address(i2c_id, dev_addr ,i2c.TRANSMITTER)
     i2c.stop(i2c_id)
     return c
end

print("Scanning...")
i2c.setup(0,sda,scl,i2c.SLOW)
for i=0,127 do
    if find_dev(0, i)==true then
    print("Device found at address 0x"..string.format("%02X",i).." ("..i..")")
    end
end

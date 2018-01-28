uart.setup(0, 921600, 8, 0, 1, 1 )
print "'init.lua'"

dofile("i2c.lua")
dofile("lcd1602.lua")

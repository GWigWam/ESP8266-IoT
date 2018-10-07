stopInit = false

local sda = 2
local scl = 1
local i2cAdr = 0x3C

local function init()
    if not stopInit then
        print("Starting...")

        gpio.mode(1, gpio.OUTPUT)
        gpio.mode(2, gpio.OUTPUT)
        gpio.write(1, gpio.LOW)
        gpio.write(2, gpio.LOW)

        local i2cw = require("i2cwriter")
        i2cw.init(sda, scl, i2cAdr)
        oled = require("SSD1306")
        gfx = require("gfx")
        num = require("gfx_num")
    end
end

uart.setup(0, 921600, 8, 0, 1, 1)
print("'init.lua'")
tmr.alarm(0,1000,0, init)

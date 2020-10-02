stopInit = false

local sda = 2
local scl = 1
local i2cAdr = 0x3C
local tzPin = 5

local function initWifi()
    dofile('secret.lua')
    wifi.setmode(wifi.STATION)
    wifi.sta.config({ssid = ssid, pwd = pwd, auto = true})
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        print("GOT_IP: "..T.IP)
        net.dns.resolve("time.nist.gov", function(sk, ip)
            if (ip == nil) then print("DNS fail!") else
                print("Got nist IP: "..ip)

                local start = function()
                    oled:cls()
                    oled:setBrightnessRange("LOW");
                    oled:setContrast(1)
                    timedisp = require('timedisp')
                    timedisp.init(tzPin)
                end
                
                local suc = function(sec, ms, srv, inf) print("Got UTC, Sec: "..sec); start(); end
                local err = function(code, msg) print("SNTP err: "..code.." ("..(msg or "no msg")..")") end
                sntp.sync(ip, suc, err, false)
            end
        end)
    end)
end

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
        oled:init()
        gfx = require("gfx")
        font = require("gfx_font")
        
        initWifi()
    end
end

uart.setup(0, 921600, 8, 0, 1, 1)
print("'init.lua'")
tmr.alarm(0,1000,0, init)

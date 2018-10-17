stopInit = false

local function init()
    if not stopInit then
        print("Starting...")

        dofile("util.lua")
        dofile("i2c.lc")
        i2cinit()
        lcd = dofile("lcd1602.lc")
        lcd:init()
        lcd:sendStr("Initializing...")

        dofile("dht.lua")
        initDHT(5, 3)
        
        dofile("httpclient.lc")
        dofile("getDHT.lua")

        dofile('secret.lua')
        wifi.setmode(wifi.STATION)
        wifi.sta.config({ssid = ssid, pwd = pwd, auto = true})
        wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
            print("GOT_IP: "..T.IP)
            lcd:setCursor(0, 1)
            lcd:sendStr(T.IP)
            tmrDelay(1000 * 3, refreshStats)
        end)
        
        setupDHTRefresh()
    end
end

uart.setup(0, 921600, 8, 0, 1, 1)
print("'init.lua'")
tmr.alarm(0,1000,0, init)

uart.setup(0, 921600, 8, 0, 1, 1 )
print("'init.lua'")

stopInit = false
tmr.alarm(0,1000,0, function()
    if not stopInit then
        print("Starting...")

        dofile("util.lua")
        dofile("i2c.lc")
        i2cinit()
        lcd = dofile("lcd1602.lc")
        lcd:init()

        wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
            lcd:setCursor(0, 1)
            lcd:sendStr(T.IP)
        end)
        lcd:sendStr("Initializing...")

        dofile('secret.lua')
        wifi.setmode(wifi.STATION)
        wifi.sta.config({ssid = ssid, pwd = pwd, auto = true})
        
        dofile("httpclient.lc")

        dofile("getDHT.lua")
        setupDHTRefresh()
    end
end)

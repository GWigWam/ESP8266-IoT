stopInit = false

pinDHTPwr = 1
pinDHTData = 2

local function init()
    if not stopInit then
        print("Starting...")
        dofile('util.lua')
        
        dofile('leds.lua')
        flash(lRed, 100)
        
        dofile('secret.lua')
        wifi.setmode(wifi.STATION)
        wifi.sta.config({ssid = ssid, pwd = pwd, auto = false})
        wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
            print("GOT_IP: "..T.IP)
            flash(lGrn, 1000)
        end)
        if wifi.sta.setmac("AA:AA:AA:E5:82:66") then print('set MAC') else print('set MAC failed') end
        if wifi.sta.setip({ip = '192.168.2.15', netmask = '255.255.255.0', gateway = '192.168.2.254'}) then print('set IP') else print('set IP failed') end
        wifi.sta.connect()

        dofile("dht.lua")
        initDHT(pinDHTData, pinDHTPwr)

        dofile("httpclient.lua");
        dofile("ThingSpeakTemp.lua")
        startTSService()

        httpsrv = dofile("httpserver.lua")(80)
        dofile("hostDHT.lua")(httpsrv)        
    end
end

uart.setup(0, 921600, 8, 0, 1, 1)
print("'init.lua'")
tmr.alarm(0,1000,0, init)

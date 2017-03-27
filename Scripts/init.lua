print('\r\n-- start of init.lua --\r\n')

dofile('util.lua')
dofile('leds.lua')
dofile('dht.lua')

-- Sets ssid and pwd vars, also sets ThingSpeak private write key
dofile('secret.lua')

wifi.setmode(wifi.STATION)

wifi.sta.sethostname("ESP8266-WG")
wifi.sta.config(ssid, pwd)
wifi.sta.connect()

tryCount = 0
conTmr = tmrRepeat(500, function()
    if wifi.sta.getip()== nil then
        print("Not yet connected...")
        flash(lRed,100)
    else
        print('\r\n-- Connection established --')
        print("  Mode: " .. wifi.getmode())
        print("  MAC: " .. wifi.ap.getmac())
        print("  IP: "..wifi.sta.getip())
        flash(lGrn,1000)
        conTmr:unregister()
    end
    
    tryCount = tryCount + 1
    if tryCount > 20 then
        print("Connect failed, stop trying for a while.")
        flash(lRed,1000)
        tryCount = 0
        wifi.sta.disconnect()
        conTmr:stop()
        tmrDelay(1000 * 20, function()
            conTmr:start()
        end)
    end
end)

dofile("ThingSpeakTemp.lua")
startTSService()

dofile("statusHost.lua")
createStatusHost()
uart.setup(0, 921600, 8, 0, 1, 1 )
print('init.lua')

dofile('util.lua')
dofile('leds.lua')
dofile('dht.lua')
-- Sets ssid and pwd vars, also sets ThingSpeak private write key
dofile('secret.lua')
dofile('wifiEvents.lua')

dofile("ThingSpeakTemp.lua")
startTSService()
http = dofile("httpserver.lua")(80)
dofile("hostDHT.lua")(http)

wifi.setmode(wifi.STATION)
wifi.sta.sethostname("ESP8266-WG")
wifi.sta.config(ssid, pwd)
wifi.sta.autoconnect(1)
if not wifi.sta.setmac("AA:AA:AA:E5:82:66") then log('set MAC failed') end
wifi.sta.connect()

tryCount = 0
tmrSemi(1000, function(conTmr)
    if wifi.sta.getip()== nil then
        flash(lRed,100)
        tryCount = tryCount + 1
        if tryCount < 20 then tryCount = tryCount +1; conTmr:start() else conTmr:unregister() end
    else conTmr:unregister() end
end)

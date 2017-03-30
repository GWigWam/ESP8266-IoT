print('\r\n-- start of init.lua --\r\n')

dofile('log.lua')
dofile('util.lua')
dofile('leds.lua')
dofile('dht.lua')
-- Sets ssid and pwd vars, also sets ThingSpeak private write key
dofile('secret.lua')

function setMac() if not wifi.sta.setmac("AA:AA:AA:E5:82:66") then log('set MAC failed') end end

function onConnect() --Shall run when connection is first established
    setMac()
    wifi.sta.autoconnect(1)
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD,function()log("STATION_WRONG_PASSWORD")end)
    wifi.sta.eventMonReg(wifi.STA_APNOTFOUND,function()log("STATION_NO_AP_FOUND")end)
    wifi.sta.eventMonReg(wifi.STA_FAIL,function()log("STATION_CONNECT_FAIL")end)
    wifi.sta.eventMonStart()

    dofile("ThingSpeakTemp.lua")
    startTSService()

    dofile("statusHost.lua")
    createStatusHost()

    startLogBackup()
end

wifi.setmode(wifi.STATION)
wifi.sta.sethostname("ESP8266-WG")
wifi.sta.config(ssid, pwd)
setMac()
wifi.sta.connect()

tryCount = 0
conTmr = tmrRepeat(500, function()
    if wifi.sta.getip()== nil then
        print("Not yet connected...")
        flash(lRed,50)
    else
        log('\r\n-- Connection established --')
        log('{ "Mode":"'..wifi.getmode()..'", "MAC":"'..wifi.ap.getmac()..'", "IP":"'..wifi.sta.getip()..'", "CH":"'..wifi.getchannel()..'" }')
        flash(lGrn,1000)
        conTmr:unregister()
        onConnect()
    end

    tryCount = tryCount + 1
    if tryCount > 20 then
        log("Connect failed, stop trying for a while.")
        flash(lRed,1000)
        tryCount = 0
        wifi.sta.disconnect()
        conTmr:stop()
        tmrDelay(1000 * 20, function()
            conTmr:start()
        end)
    end
end)

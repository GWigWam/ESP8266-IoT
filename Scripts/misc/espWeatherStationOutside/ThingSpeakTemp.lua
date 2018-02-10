tsField1 = -1
tsField2 = -1

function setupTS()
    tsCon = net.createConnection(net.TCP, 0)
 
    tsCon:on("receive", function(tsCon, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Stat send success 200 (OK)");
            flash(lGrn,50)
        else
            print("Stat send failed: "..payloadout)
            flash(lRed,50)
        end
    end)
 
    tsCon:on("connection", function(tsCon, payloadout)
        tsCon:send("GET /update?api_key="..tsApiKey.."&field1="..tsField1.."&field2="..tsField2
        .. " HTTP/1.1\r\n"
        .. "Host: api.thingspeak.com\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n")
    end)
    
    tsCon:on("disconnection", function(tsCon, payloadout)
        collectgarbage();
    end)
    
    return function() tsCon:connect(80,'api.thingspeak.com') end
end

tsSendFunc = nil
tsTempBuffer = {}
tsHumiBuffer = {}

function tsTick()
    local tsMinMeasureCount = 3
    success, temp, humi = getDHTStats()
    if success then
        print('Took succesfull measurement, T='..temp..'c H='..humi..'%')
        table.insert(tsTempBuffer, temp)
        table.insert(tsHumiBuffer, humi)
                
        if #tsTempBuffer >= tsMinMeasureCount then
            tsField1 = tableMedian(tsTempBuffer)
            tsField2 = tableMedian(tsHumiBuffer)
            tsSendFunc()
            tsTempBuffer = {}
            tsHumiBuffer = {}
        end
    end
end

tsTmr = nil
function startTSService()
    local tsReportIntervalMs = 1000 * 60
    if tsSendFunc == nil then
        tsSendFunc = setupTS()
    end
    tsTmr = tmrRepeat(tsReportIntervalMs, tsTick)
    print('started ThingSpeakTemp')
end

function stopTSService()
    tsTmr:unregister()
end

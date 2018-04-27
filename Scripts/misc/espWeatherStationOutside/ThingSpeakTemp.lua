tsField1 = -1
tsField2 = -1

function setupTS()
    return function()
        local rq = {
            method = "POST",
            host = "api.thingspeak.com",
            resource = ("/update?api_key="..tsApiKey.."&field1="..tsField1.."&field2="..tsField2)
        }
        local hndl = function(succ, resp)
            if success and string.match(resp.status, "200") then
                print("Stat sent");
                flash(lGrn,50)
            else
                print("Stat sent failed: "..payloadout)
                flash(lRed,50)
            end
        end
        sendHttpRequest(rq, hndl)
    end
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

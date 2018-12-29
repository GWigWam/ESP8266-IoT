local refInterval = 1000 * 60 * 5
local timer = nil
local lcdLine0 = ''
local lcdLine1 = ''

local function frmat(t, h) return string.format("%.1fßC | %i%%", t, h) end

local function parse(body)
    local t = string.match(body, '"temp": ?([0-9\.\-]+)')
    local h = string.match(body, '"humi": ?([0-9\.\-]+)')
    local tn = tonumber(t)
    local th = tonumber(h)
    if h and t then
        return frmat(tn, th)
    else
        return "Parse fail"
    end
end

local function updateLcd()
    lcd:cls()
    lcd:sendStr(lcdLine0)
    lcd:setCursor(0, 1)
    lcd:sendStr(lcdLine1)
end

local function servDHT()
   local rq = {
        method = "GET",
        host = "192.168.2.15",
        resource = "/DHT",
        headers = {
            ["Accept"] = "*/*"
        }
    };
    local hndl = function(success, resp)
        local t = ""
        if success then
            if string.match(resp.status, "200") and resp.body then
                t = parse(resp.body)
            else
                t = resp.status
                success = false
            end
        else
            t = "Connection failed"
        end
        lcdLine0 = t
        updateLcd()
        local intrvl = success and refInterval or 10000
        timer:interval(intrvl)
    end
    sendHttpRequest(rq, hndl)
end

local function localDHT()
    suc, temp, humi = getDHTStats()
    if suc then
        lcdLine1 = frmat(temp, humi)
    else
        lcdLine1 = "Read error"
    end
end

function refreshStats()
    print("refresh");
    localDHT()
    servDHT()
end

function setupDHTRefresh()
    if timer == nil then
        timer = tmr.create()
        timer:register(refInterval, tmr.ALARM_AUTO, refreshStats)
        timer:start()
    end
end

function stopDHTRefresh()
    timer:unregister()
    timer = nil
end

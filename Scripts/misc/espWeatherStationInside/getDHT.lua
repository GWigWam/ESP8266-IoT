local timer = nil

local function parse(body)
    local t = string.match(body, '"temp": ?([0-9\.\-]+)')
    local h = string.match(body, '"humi": ?([0-9\.\-]+)')
    local tn = tonumber(t)
    local th = tonumber(h)
    if h and t then
        return string.format("%.1fßC | %i%%", tn, th)
    else
        return "Parse fail"
    end
end

function setupDHTRefresh()
    local rq = {
        method = "GET",
        host = "192.168.2.15",
        resource = "/DHT",
        headers = {
            ["Accept"] = "*/*"
        }
    };

    local h = function(success, resp)
        local t = ""
        if success then
            if string.match(resp.status, "200") and resp.body then
                t = parse(resp.body)
            else
                t = resp.status 
            end
        else
            t = "Connection failed"
        end
        print(t)
        lcd:cls()
        lcd:sendStr(t)
    end

    local refresh = function() print("Refresh DHT info"); sendHttpRequest(rq, h) end
    timer = tmrRepeat(1000 * 60 * 5, refresh)
    tmrDelay(1000 * 10, refresh)
end

function stopDHTRefresh()
    timer:stop()
end

local function handler(req)
    if req.method == "GET" and req.url[1] == "DHT" then
        success, temp, humi = getDHTStats()
        if success then
            body = string.format('{ "temp":%f, "humi":%f }', temp, humi)
            return true, { status = "200 OK", body = body, headers = { ["Content-Type"] = "application/json" } }
        else
            return true, { status = "500 Internal Server Error", body = "Failure reading DHT" }
        end
    end
    return false
end

return function(http)
    print("'hostDHT.lua'")
    http:addHandler(handler)
end

function receiver(sck, data)
    local response = {}
    
    -- sends and removes the first element from the 'response' table
    local function send(localSocket)
        if #response > 0 then
            localSocket:send(table.remove(response, 1))
        else
            localSocket:close()
            response = nil
        end
    end
       
    response[#response + 1] = "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\n\r\n"
    
    reqUrl = string.sub(string.match(data, 'GET /%w*'),5,-1)
    print('Incomming request to ' .. reqUrl)
    if reqUrl == '/' then
        success, temp, humi = getDHTStats()
        if success then
            response[#response + 1] = "Temp=" .. temp .. "C, Humi=" .. humi .. "%"
        else
            response[#response + 1] = "Measurement failed"
        end
    elseif reqUrl == '/flash' then
        flash(lGrn,500)
        tmrDelay(400,function() flash(lRed,500)end)
    else
        response[#response + 1] = "URL not in use"
    end
    
    sck:on("sent", send)    
    send(sck)
end

function createStatusHost()
    srv = net.createServer(net.TCP, 100)
    srv:listen(80, function(conn)
        conn:on("receive", receiver)
    end)
    print('started statusHost')
    
    function stopStatusHost()
        srv:close()
    end
end
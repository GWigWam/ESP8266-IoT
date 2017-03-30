function receiver(sck, data)
    local rsp = {}
    
    -- sends and removes the first element from the 'rsp' table
    local function send(localSocket)
        if #rsp > 0 then
            localSocket:send(table.remove(rsp, 1))
        else
            localSocket:close()
            rsp = nil
        end
    end
    table.insert(rsp, "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\n\r\n")
    
    reqUrl = string.sub(string.match(data, 'GET /%w*'),5,-1)
    log('Incomming request to ' .. reqUrl)
    if reqUrl == '/' then
        success, temp, humi = getDHTStats()
        if success then
            table.insert(rsp, "Temp=" .. temp .. "C, Humi=" .. humi .. "%")
        else
            table.insert(rsp, "Measurement failed")
        end
        table.insert(rsp,"\r\n\r\nLOG:")
        table.foreach(lLog, function(k,v)table.insert(rsp, '\r\n  > '..v)end)
    elseif reqUrl == '/flash' then
        flash(lGrn,500)
        tmrDelay(400,function() flash(lRed,500)end)
    else
        table.insert(rsp, "URL not in use")
    end
    
    table.insert(rsp, '\r\n')
    sck:on("sent", send)    
    send(sck)
end

function createStatusHost()
    srv = net.createServer(net.TCP, 100)
    srv:listen(80, function(conn)
        conn:on("receive", receiver)
    end)
    log('started statusHost')
    
    function stopStatusHost()
        srv:close()
    end
end
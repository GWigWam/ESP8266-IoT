function receiver(sck, data)
    local rsp = {}
    table.insert(rsp, "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\n")
    
    reqUrl = string.sub(string.match(data, 'GET /%w*'),5,-1)
    log('Incomming request to ' .. reqUrl)
    if reqUrl == '/' then
        success, temp, humi = getDHTStats()
        if success then
            table.insert(rsp, "Temp=" .. temp .. "C, Humi=" .. humi .. "%")
        else
            table.insert(rsp, "Measurement failed")
        end
        table.insert(rsp,"\r\nLOG:")
        table.foreach(lLog, function(k,v)table.insert(rsp, ' > '..v)end)
    elseif reqUrl == '/flash' then
        flash(lGrn,500)
        tmrDelay(500,function() flash(lRed,500)end)
        tmrDelay(1000,function() flash(lBlu,500)end)
    else
        rsp = {"HTTP/1.0 404 NOT FOUND\r\n"}
    end
    
    table.insert(rsp, '\r\n\r\n')
    full = table.concat(rsp, '\r\n')
    sck:send(full)
    sck:on("sent", function()
        sck:close()
        rsp = nil
    end)
end

function createStatusHost()
    srv = net.createServer(net.TCP, 100)
    srv:listen(80, function(conn)
        conn:on("receive", receiver)
    end)
    log('started statusHost')
    
    function stopStatusHost()
        srv:close()
        log('stop statusHost')
    end
end
print("'httpclient.lua'")
    
local function onResponse(resp, handler)
    local b0, b1 = string.find(resp, "\r?\n\r?\n")
    local head = string.sub(resp, 0, b0 or #resp)
    local body = string.sub(resp, (b1 or #resp) + 1)
    local r0, r1 = string.find(head, "\r?\n")
    local rql = string.sub(head, 0, r0)
    local hdrs = string.sub(head, r1 + 1)
    local status = string.match(rql, "[^ ]+ ([^\r\n]+)")

    local hdrTbl = {}
    for ch in string.gmatch(hdrs, "[^\r\n]+") do
        n, v = string.match(ch, "([^:]+) ?: ?(.+)")
        hdrTbl[n] = v
    end

    handler(true, { status = status, headers = hdrTbl, body = body })
end

function sendHttpRequest(req, handler)
    local r = {}
    table.insert(r, string.format("%s %s HTTP/1.0", req.method or "GET", req.resource or "/"))
    local hdrTbl = { ["Host"] = req.host, ["Connection"] = "close" }
    if req.body then hdrTbl["Content-Length"] = (#req.body + 2) end
    for k, v in pairs(req.headers or {}) do hdrTbl[k] = v end
    for k, v in pairs(hdrTbl) do table.insert(r, string.format("%s: %s", k, v)) end
    if req.body then table.insert(r, string.format("\r\n%s", req.body)) end
    table.insert(r, "\r\n")
    local full = table.concat(r, '\r\n')

    local srv = net.createConnection(net.TCP, 0)
    srv:on("connection",
        function(sck)
            sck:send(full)
        end
    )
    
    local incomming = {}
    srv:on("receive",  function(sck, data) table.insert(incomming, data) end)
    srv:on("disconnection", function(sck)
        if #incomming > 0 then
            onResponse(table.concat(incomming), handler)
        else
            handler(false)
        end
    end)
    
    srv:connect(req.port or 80, req.host)
end

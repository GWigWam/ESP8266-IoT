local state = { srv = nil, handlers = {} }

local function parseReq(req)
    local b0, b1 = string.find(req, "\r?\n\r?\n")
    local head = string.sub(req, 0, b0 or #req)
    local body = string.sub(req, (b1 or #req) + 1)
    local r0, r1 = string.find(head, "\r?\n")
    local rql = string.sub(head, 0, r0)
    local hdrs = string.sub(head, r1 + 1)

    local hdrTbl = {}
    for ch in string.gmatch(hdrs, "[^\r\n]+") do
        n, v = string.match(ch, "([^:]+) ?: ?(.+)")
        hdrTbl[n] = v
    end
    
    local metStr, urlStr = string.match(rql, "(%a+) ([^ ]+)")
    url = {}
    for p in string.gmatch(urlStr, "[^/]+") do
        url[#url + 1] = p
    end
        
    return { method = metStr, url = url, headers = hdrTbl, body = body }
end

local function onReceive(sck, data)
    local req = parseReq(data)
    local hdata = {}
    for i = #state.handlers, 1, -1 do
        handled, hdata = state.handlers[i](req)
        if handled then break end
    end

    local rsp = {}
    table.insert(rsp, string.format("HTTP/1.0 %s\r\nServer: NodeMCU on ESP8266", hdata.status))
    for hn, hv in pairs(hdata.headers or {}) do
        table.insert(rsp, string.format("%s: %s", hn, hv))
    end
    if hdata.body then
        table.insert(rsp, string.format("Content-Length: %i", #hdata.body))
        table.insert(rsp, string.format("\r\n%s\r\n", hdata.body))
    end
    full = table.concat(rsp, '\r\n')
    sck:send(full)
    sck:on("sent", function() sck:close() end)
end

local function init(self)
    self.srv = net.createServer(net.TCP)
    self.srv:listen(80, function(sck) sck:on("receive", onReceive) end)
end

local function stop(self) self.srv:close() end

local function addHandler(self, fnc)
    table.insert(self.handlers, fnc)
end

local function lastHandler(req)
    return true, { status = "404 Not Found", headers = { Test = "val", ["Content-Type"] = "plain/text" }, body = "No resource found." }
end

-- Class def:
return function()
    print("'httpserver.lua'")
    local meta = { __index = { stop = stop, addHandler = addHandler } }
    local this = setmetatable(state, meta)
    init(this)
    addHandler(this, lastHandler)
    return this
end

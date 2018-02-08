local function onReceive(sck, data)
    local rsp = {}
    table.insert(rsp, "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\n")
    table.insert(rsp, "Success!")
    table.insert(rsp, "\r\n")
    full = table.concat(rsp, '\r\n')
    sck:send(full)
    sck:on("sent", function() sck:close() end)
end

local function init(self)
    srv = net.createServer(net.TCP)
    srv:listen(80, function(conn) conn:on("receive", onReceive) end)
end

function stop(self) self.srv:close() end

-- Class def:
print("'httpserver.lua'")
local meta = { __index = { stop = stop } }
local state = { srv = nil }
local http = setmetatable(state, meta)
init(self)
return http

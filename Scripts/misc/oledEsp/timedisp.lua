print("'timedisp.lua'")

local this = {}
local oled = require('SSD1306')
local gfx = require('gfx')

this.tmrs = {}

local function delay(ms, func)
    local ltmr = tmr.create()
    ltmr:register(ms, tmr.ALARM_SEMI, func)
    ltmr:start()
    this.tmrs[#this.tmrs + 1] = ltmr
end

local disp = {
    ["sec"] =   { "%02d", 2, 96, 1 },
    ["min"] =   { "%02d:", 2, 48, 1 },
    ["hour"] =  { "%02d:", 2, 0, 1 },
    ["day"] =   { "%02d", 1, 62, 0 },
    ["mon"] = { "%02d-", 1, 40, 0 },
    ["year"] =  { "%02d-", 1, 0, 0 }
}
local function drawTime()
    s,us,r = rtctime.get()
    if s > 0 then
        dt = rtctime.epoch2cal(s)
        for k, v in pairs(disp) do
            local cur = dt[k]
            if v[5] ~= cur then
                local str = string.format(v[1], cur)
                for f in gfx.iterWriteStr(str, v[2], v[3], v[4]) do f() end
                v[5] = cur
                tmr.wdclr()
            end
        end
    end
end

this.init = function()
    delay(500, function(t)
        drawTime()
        t:start()
    end)    
end

this.stop = function()
    for i=1, #this.tmrs do this.tmrs[i]:unregister() end
end

return this

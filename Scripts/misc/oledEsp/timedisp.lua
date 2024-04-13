print("'timedisp.lua'")

local this = {}
local oled = require('SSD1306')
local gfx = require('gfx')
local timezone = nil

this.tmrs = {}

local function delay(ms, func)
    local ltmr = tmr.create()
    ltmr:register(ms, tmr.ALARM_SEMI, func)
    ltmr:start()
    this.tmrs[#this.tmrs + 1] = ltmr
end

local disp = {
    ["min"] =   { "%02d", 4, 64, 1 },
    ["hour"] =  { "%02d", 4, 0, 1 },
    ["day"] =   { "%02d", 1, 62, 0 },
    ["mon"] =   { "%02d-", 1, 40, 0 },
    ["year"] =  { "%02d-", 1, 0, 0 }
}
local inverse = false
local function drawTime()
    s,us,r = rtctime.get()
    if s > 0 then
        dt = rtctime.epoch2cal(s)
        dt["hour"] = (dt["hour"] + timezone.getOffset() + 1) % 24
        
        -- Full redraw every 5min
        local fullRedraw = function() for k, v in pairs(disp) do disp[k][5] = nil end end
        if (dt["min"] % 5 == 0) and (dt["sec"] == 30) then fullRedraw() end
        
        -- ToString disp:
        for k, v in pairs(disp) do
            local cur = dt[k]
            if v[5] ~= cur then
                local str = string.format(v[1], cur)
                for f in gfx.iterWriteStr(str, v[2], v[3], v[4]) do f() end
                v[5] = cur
                tmr.wdclr()
            end
        end

        -- Seconds bar:
        local v = (dt["min"] % 2 == 0) and 0xC0 or 0x00
        local len = (dt["sec"] * 2)
        oled:writeAt({ v, v }, len, 7, len+1, 7)
        
        -- Hourly refresh:
        if inverse then
            oled:setInverse(false)
            inverse = false
        end
        if dt["min"] + dt["sec"] == 0 then
            oled:setInverse(true)
            oled:cls()
            fullRedraw()
            inverse = true
        end
    end
end

this.init = function(tzPin)
    timezone = require('timezoneSwitch')(tzPin)
    delay(500, function(t)
        drawTime()
        t:start()
    end)
end

this.stop = function()
    for i=1, #this.tmrs do this.tmrs[i]:unregister() end
end

return this

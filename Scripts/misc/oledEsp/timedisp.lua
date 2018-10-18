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

local function drawTime()
    s,us,r = rtctime.get()
    if s > 0 then
        dt = rtctime.epoch2cal(s)
        local str = string.format("%02d:%02d:%02d", dt.hour, dt.min, dt.sec)
        for f in gfx.iterWriteStr(str, 2, 0, 2) do f() end
    end
end

this.init = function()
    delay(1000, function(t)
        drawTime()
        t:start()
    end)    
end

this.stop = function()
    for i=1, #this.tmrs do this.tmrs[i]:unregister() end
end

return this

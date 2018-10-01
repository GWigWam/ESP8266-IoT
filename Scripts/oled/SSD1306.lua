-- SSD1306.lua by GWigWam

local cmd = function(self, vals)
    if type(vals) ~= "table" then vals = { vals }  end

    for i = 1, #vals do
        print(string.format("cmd_%i> 0x%x", i, vals[i]))
        i2cw({ 0x00, vals[i] })
    end
end

local setMemAdrMode = function(self, mode)
    cmd(self, { self.const["SETMEMADRMODE"], mode })
end

local setContrast = function(self, contrast)
    if contrast < 0 or contrast > 255 then error("Contrast must be 0 - 255") end
    cmd(self, { self.const["SETCONTRAST"], contrast })
end

local setInverse = function(self, useInverse)
    cmd(self, useInverse and self.const["DISPLAYINVERSE"] or self.const["DISPLAYNORMAL"])
end

local setOn = function(self)
    cmd(self, self.const["DISPLAYON"])
    tmr.delay(100)
end

local setOff = function(self)
    cmd(self, self.const["DISPLAYOFF"])
    tmr.delay(100)
end

local init = function(self)
    setOff(self)

    cmd(self, { self.const["SETDISPLAYCLOCKDIV"], self.const["DISPLAYCLOCKDIV_DEF"] }) -- Set display clock divide to reccomended value
    cmd(self, { self.const["SETMULTIPLEXRATIO"], self.const["SCREENHEIGHT"] - 1 }) -- Set multiplex ratio to (screen height - 1)
    cmd(self, { self.const["SETDISPLAYOFFSET"], 0x00 }) -- Set display offset to 0
    cmd(self, bit.bor(self.const["SETSTARTLINE"], 0x00)) -- Set starting line to 0
    cmd(self, { self.const["SETCHARGEPUMP"], self.const["CHARGEPUMP"]["ON"] }) -- Enable charge pump
    setMemAdrMode(self, self.const["MEMADRMODE"]["HORIZONTAL"]) -- Set memory addressing mode to horizontal mode    
    cmd(self, self.const["SETSEGMENTMAP_127"]) -- Set segment re-map
    cmd(self, self.const["SETCOMSCANDIR_REV"]) -- Set COM Output scan direction
    cmd(self, { self.const["SETCOMPINS"], self.const["COMPINS_DEF"] }) -- Set default hardware COM pin configuration
    cmd(self, { self.const["SETPRECHARGE"], self.const["PRECHARGE_DEF"] }) -- Set pre-charge period to default
    cmd(self, { self.const["SETVCOMDETECT"], self.const["VCOMDETECT_DEF"] }) -- Set V_Comh deselect voltage level to default
    cmd(self, self.const["DISPLAYRAMON"]) -- Display RAM content to screen (Alternative 'DISPLAYRAMOFF')
    cmd(self, self.const["DEACTIVATE_SCROLL"]) -- Deactivate scrolling mode

    setContrast(self, 128)
    setInverse(self, false)
    setOn(self)
end

-- Class def:
print("'SSD1306.lua'")
local meta = { __index = { setContrast = setContrast, setInverse = setInverse, setOn = setOn, setOff = setOff, init = init } }
local state = {
    const = dofile("SSD1306_const.lua")
}
return setmetatable(state, meta)

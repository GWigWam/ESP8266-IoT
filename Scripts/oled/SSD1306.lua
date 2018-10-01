-- SSD1306.lua by GWigWam

local function cmd(vals)
    if type(vals) ~= "table" then vals = { vals }  end

    for i = 1, #vals do
        print(string.format("cmd_%i> 0x%x", i, vals[i]))
        i2cw({ 0x00, vals[i] })
    end
end

local function wSegment(val)
    i2cw({ 0x40, val})
end

local setMemAdrMode = function(self, mode)
    cmd({ self.const["SETMEMADRMODE"], mode })
end

local setColAdr = function(self, from, to)
    local maxCol = self.const["SCREENWIDTH"] - 1
    if from < 0 or from > maxCol then error("From must be 0 - 128") end
    if to < 0 or to > maxCol then error("To must be 0 - 128") end
    cmd({ self.const["SETCOLADR"], from, to })
end

local setPageAdr = function(self, from, to)
    local maxPage = self.const["PAGECOUNT"] - 1
    if from < 0 or from > maxPage then error("From must be 0 - 128") end
    if to < 0 or to > maxPage then error("To must be 0 - 128") end
    cmd({ self.const["SETPAGEADR"], from, to })
end

local resetAdr = function(self)
    setColAdr(self, 0, self.const["SCREENWIDTH"] - 1)
    setPageAdr(self, 0, self.const["PAGECOUNT"] - 1)
end

local setContrast = function(self, contrast)
    if contrast < 0 or contrast > 255 then error("Contrast must be 0 - 255") end
    cmd({ self.const["SETCONTRAST"], contrast })
end

local setInverse = function(self, useInverse)
    cmd(useInverse and self.const["DISPLAYINVERSE"] or self.const["DISPLAYNORMAL"])
end

local setOn = function(self)
    cmd(self.const["DISPLAYON"])
    tmr.delay(100)
end

local setOff = function(self)
    cmd(self.const["DISPLAYOFF"])
    tmr.delay(100)
end

local cls = function(self)
    resetAdr(self)
    setMemAdrMode(self, self.const["MEMADRMODE"]["HORIZONTAL"])
    for i = 0, self.const["SEGMENTCOUNT"] do
        wSegment(0x00)
        tmr.wdclr()
    end
end

local init = function(self)
    setOff(self)

    cmd({ self.const["SETDISPLAYCLOCKDIV"], self.const["DISPLAYCLOCKDIV_DEF"] }) -- Set display clock divide to reccomended value
    cmd({ self.const["SETMULTIPLEXRATIO"], self.const["SCREENHEIGHT"] - 1 }) -- Set multiplex ratio to (screen height - 1)
    cmd({ self.const["SETDISPLAYOFFSET"], 0x00 }) -- Set display offset to 0
    cmd(bit.bor(self.const["SETSTARTLINE"], 0x00)) -- Set starting line to 0
    cmd({ self.const["SETCHARGEPUMP"], self.const["CHARGEPUMP"]["ON"] }) -- Enable charge pump
    setMemAdrMode(self, self.const["MEMADRMODE"]["HORIZONTAL"]) -- Set memory addressing mode to horizontal mode    
    cmd(self.const["SETSEGMENTMAP_127"]) -- Set segment re-map
    cmd(self.const["SETCOMSCANDIR_REV"]) -- Set COM Output scan direction
    cmd({ self.const["SETCOMPINS"], self.const["COMPINS_DEF"] }) -- Set default hardware COM pin configuration
    cmd({ self.const["SETPRECHARGE"], self.const["PRECHARGE_DEF"] }) -- Set pre-charge period to default
    cmd({ self.const["SETVCOMDETECT"], self.const["VCOMDETECT_DEF"] }) -- Set V_Comh deselect voltage level to default
    cmd(self.const["DISPLAYRAMON"]) -- Display RAM content to screen (Alternative 'DISPLAYRAMOFF')
    cmd(self.const["DEACTIVATE_SCROLL"]) -- Deactivate scrolling mode

    setContrast(self, 128)
    setInverse(self, false)
    setOn(self)
end

-- Class def:
print("'SSD1306.lua'")
local meta = {
    __index = {
        cmd = cmd, wSegment = wSegment,
        setMemAdrMode = setMemAdrMode, setColAdr = setColAdr, setPageAdr = setPageAdr, resetAdr = resetAdr,
        setContrast = setContrast, setInverse = setInverse,
        setOn = setOn, setOff = setOff,
        cls = cls, init = init
    }
}
local state = {
    const = dofile("SSD1306_const.lua")
}
return setmetatable(state, meta)

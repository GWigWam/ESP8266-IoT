-- SSD1306.lua by GWigWam

local function cmd(self, vals)
    if type(vals) ~= "table" then vals = { vals }  end

    for i = 1, #vals do
        self.i2cw.w({ self.const["COMMANDMODE"], vals[i] })
    end
end

local function rawWrite(self, vals)
    if type(vals) ~= "table" then vals = { vals }  end

    local wt = { self.const["WRITEMODE"] }
    for i=1,#vals do
        wt[i + 1] = vals[i]
    end
    self.i2cw.w(wt)
end

local setMemAdrMode = function(self, mode)
    cmd(self, { self.const["SETMEMADRMODE"], mode })
end

local setColAdr = function(self, from, to)
    local maxCol = self.const["SCREENWIDTH"] - 1
    if from < 0 or from > maxCol then error("From must be 0 - 128") end
    if to < 0 or to > maxCol then error("To must be 0 - 128") end
    cmd(self, { self.const["SETCOLADR"], from, to })
end

local setPageAdr = function(self, from, to)
    local maxPage = self.const["PAGECOUNT"] - 1
    if from < 0 or from > maxPage then error("From must be 0 - 128") end
    if to < 0 or to > maxPage then error("To must be 0 - 128") end
    cmd(self, { self.const["SETPAGEADR"], from, to })
end

local resetAdr = function(self)
    setColAdr(self, 0, self.const["SCREENWIDTH"] - 1)
    setPageAdr(self, 0, self.const["PAGECOUNT"] - 1)
end

local function writeAt(self, vals, x0, p0, x1, p1)
    if x1 == nil then x1 = x0 + 8 end
    if p1 == nil then p1 = p0 end
    setColAdr(self, x0, x1)
    setPageAdr(self, p0, p1)
    rawWrite(self, vals)
    resetAdr(self)
end

local setBrightnessRange = function(self, levelStr)
    local lvl = self.const["DESELECTLVLS"][levelStr];
    if(lvl == nil) then error("Invalid level string, try: 'LOW', 'MED', 'HIGH', 'ULTRA'.") end
    cmd(self, { self.const["SETVCOMHDESELECTLVL"], lvl });
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

local cls = function(self)
    resetAdr(self)
    setMemAdrMode(self, self.const["MEMADRMODE"]["HORIZONTAL"])
    local t = {}
    for j = 1, self.const["SCREENWIDTH"] do
        t[j] = 0x00
    end
    for i = 1, self.const["PAGECOUNT"] do
        rawWrite(self, t)
    end
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
    setBrightnessRange(self, "MED"); -- Set V_Comh deselect level to 0.77volt (Default value)
    cmd(self, self.const["DISPLAYRAMON"]) -- Display RAM content to screen (Alternative 'DISPLAYRAMOFF')
    cmd(self, self.const["DEACTIVATE_SCROLL"]) -- Deactivate scrolling mode

    setContrast(self, 128)
    setInverse(self, false)
    setOn(self)
end

-- Class def:
print("'SSD1306.lua'")
local meta = {
    __index = {
        cmd = cmd, rawWrite = rawWrite, writeAt = writeAt,
        setMemAdrMode = setMemAdrMode, setColAdr = setColAdr, setPageAdr = setPageAdr, resetAdr = resetAdr,
        setBrightnessRange = setBrightnessRange, setContrast = setContrast, setInverse = setInverse,
        setOn = setOn, setOff = setOff,
        cls = cls, init = init
    }
}
local state = {
    const = require("SSD1306_const"),
    i2cw = require("i2cwriter")
}
return setmetatable(state, meta)

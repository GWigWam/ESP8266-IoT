-- lcd1602.lua by GWigWam

local send = function(self, vals, rs)
    if type(vals) ~= "table" then vals = {vals} end
    local blBit = self.bl and self.const["BACKLIGHT"] or self.const["NOBACKLIGHT"]
    local rsBit = rs and self.const["RsBit"] or 0x00

    local debStr = string.format("snd (%i):", #vals)
    for i = 1, #vals do
        debStr = string.format("%s 0x%02X |", debStr, vals[i])
    end
    print(debStr)
    
    local tbl = { 0x00 } -- TODO, might not be necisary, use '{ }' instead
    for i = 1, #vals do
        local payl = bit.bor(vals[i], blBit, rsBit)
        table.insert(tbl, bit.bor(payl, self.const["EnBit"]))
        table.insert(tbl, payl)
    end
    i2cw(tbl)
end

local sendChar = function(self, char)
    local c = string.byte(char)
    local m0 = bit.band(c, 0xF0)
    local m1 = bit.lshift(bit.band(c, 0x0F), 4)
    send(self, {m0,m1}, true)
end

local init = function(self) -- As specified on page 46 of HD44780U specsheet
    send(self, 0x30) -- set 8bit interface
    tmr.delay(4500)  -- 4.1ms
    send(self, 0x30)
    tmr.delay(4500)
    send(self, 0x30)
    tmr.delay(120) -- 100ns

    local func = bit.bor(self.const["4BITMODE"], self.const["2LINE"], self.const["5x8DOTS"])
    local cntr = bit.bor(self.const["DISPLAYON"], self.const["CURSORON"], self.const["BLINKON"])
    local mode = bit.bor(self.const["ENTRYLEFT"], self.const["ENTRYSHIFTDECREMENT"])

    send(self, { bit.bor(self.const["FUNCTIONSET"], self.const["4BITMODE"]) }) -- Set 4-bit mode
    send(self, { self.const["FUNCTIONSET"], bit.lshift(func, 4) }) -- Function set (NoLines, Font)
    send(self, { 0x00, bit.lshift(bit.bor(self.const["DISPLAYCONTROL"], cntr), 4) }) -- Control set (On/off, Cursor, Blink)
    self:cls()
    send(self, { 0x00, bit.lshift(bit.bor(self.const["ENTRYMODESET"], mode), 4) }) --Entry mode set (Align, Disp. shift)
    
    tmr.delay(2000)
end

local cls = function(self)
    send(self, {0x00, bit.lshift(self.const["CLEARDISPLAY"], 4)})
    tmr.delay(2000)
end

local setCursor = function(self, col, row)
    send(self, {
        bit.bor(self.const["SETDDRAMADDR"], self.row_offsets[row + 1]),
        bit.lshift(col, 4)
    })
end

local sendStr = function(self, str)
    for i = 1, #str do sendChar(self, string.sub(str, i, i)) end
end

-- Class def:
print("'lcd1602.lua'")
local meta = { __index = { init = init, cls = cls, setCursor = setCursor, sendStr = sendStr } }
local state = {
    bl = true,
    row_offsets = { 0x00, 0x40 },
    const = dofile("lcd1602_const.lua")
}
return setmetatable(state, meta)

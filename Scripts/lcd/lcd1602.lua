-- lcd1602.lua by GWigWam
lcdDebug = false

-- Send 4 bits, 4 most significant bits of each byte 'val' in @vals table will be sent.
--  Pass @rs bool to set register selector (RS) pin: 0 = instruction register, 1 = data register.
local send4b = function(self, vals, rs)
    if type(vals) ~= "table" then vals = {vals} end

    local blBit = self.bl and self.const["BACKLIGHT"] or self.const["NOBACKLIGHT"]
    local rsBit = rs and self.const["RsBit"] or 0x00

    local tbl = { }
    for i = 1, #vals do
        local cur = bit.band(vals[i], 0xF0)
        local payl = bit.bor(cur, blBit, rsBit)
        table.insert(tbl, bit.bor(payl, self.const["EnBit"]))
        table.insert(tbl, payl)
    end
    i2cw(tbl)
end

-- Calls send4b twice to send full byte.
local sendByte = function(self, vals, rs)
    if type(vals) ~= "table" then vals = {vals} end

    local tbl = { }
    local debStr = string.format("snd (%i):", #vals)
    for i = 1, #vals do
        table.insert(tbl, bit.band(vals[i], 0xF0))
        table.insert(tbl, bit.lshift(bit.band(vals[i], 0x0F), 4))
        debStr = string.format("%s 0x%02X |", debStr, vals[i])
    end
    send4b(self, tbl, rs)
    if lcdDebug then print(debStr) end
end

local init = function(self) -- As specified on page 46 of HD44780U specsheet
    send4b(self, 0x30) -- set 8bit interface
    tmr.delay(4500)  -- 4.1ms
    send4b(self, 0x30)
    tmr.delay(4500)
    send4b(self, 0x30)
    tmr.delay(120) -- 100ns
    send4b(self, { bit.bor(self.const["FUNCTIONSET"], self.const["4BITMODE"]) }) -- Set 4-bit mode

    local func = bit.bor(self.const["4BITMODE"], self.const["2LINE"], self.const["5x8DOTS"])
    local cntr = bit.bor(self.const["DISPLAYON"], self.const["CURSOROFF"], self.const["BLINKOFF"])
    local mode = bit.bor(self.const["ENTRYLEFT"], self.const["ENTRYSHIFTDECREMENT"])

    sendByte(self, bit.bor(self.const["FUNCTIONSET"], func)) -- Function set (NoLines, Font)
    sendByte(self, bit.bor(self.const["DISPLAYCONTROL"], cntr)) -- Control set (On/off, Cursor, Blink)
    self:cls()
    sendByte(self, bit.bor(self.const["ENTRYMODESET"], mode)) --Entry mode set (Align, Disp. shift)

    tmr.delay(2000)
end

local cls = function(self)
    sendByte(self, self.const["CLEARDISPLAY"])
    tmr.delay(500 * 1000)
end

local setCursor = function(self, col, row)
    sendByte(self, bit.bor(self.const["SETDDRAMADDR"], self.row_offsets[row + 1], col))
end

local sendChar = function(self, char)
    sendByte(self, string.byte(char), true)
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
    const = dofile("lcd1602_const.lc")
}
return setmetatable(state, meta)

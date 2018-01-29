-- lcd1602.lua by GWigWam
const = dofile("lcd1602_const.lua");
print "'lcd1602.lua'"

backlight = true

function begin() -- As specified on page 46 of HD44780U specsheet
    send(0x30) -- set 8bit interface
    tmr.delay(4500)  -- 4.1ms
    send(0x30)
    tmr.delay(4500)
    send(0x30)
    tmr.delay(120) -- 100ns

    local func = bit.bor(const["4BITMODE"], const["2LINE"], const["5x8DOTS"])
    local cntr = bit.bor(const["DISPLAYON"], const["CURSORON"], const["BLINKON"])    
    local mode = bit.bor(const["ENTRYLEFT"], const["ENTRYSHIFTDECREMENT"])

    send({ bit.bor(const["FUNCTIONSET"], const["4BITMODE"]) }) -- Set 4-bit mode
    send({ const["FUNCTIONSET"], bit.lshift(func, 4) }) -- Function set (NoLines, Font)
    send({ 0x00, bit.lshift(bit.bor(const["DISPLAYCONTROL"], cntr), 4) }) -- Control set (On/off, Cursor, Blink)
    clear()
    send({ 0x00, bit.lshift(bit.bor(const["ENTRYMODESET"], mode), 4) }) --Entry mode set (Align, Disp. shift)
    
    tmr.delay(2000)
end

function clear()
    send({0x00, bit.lshift(const["CLEARDISPLAY"], 4)})
    tmr.delay(2000)
end

function setCursor(row, col)
    local row_offsets = { 0x00, 0x40 }
    local offset = row_offsets[row + 1]
    send({ bit.bor(const["SETDDRAMADDR"], offset), bit.lshift(col, 4) })
end

function sendStr(str)
    for i = 1, #str do sendChar(string.sub(str, i, i)) end
end

function sendChar(char)
    local c = string.byte(char)
    local m0 = bit.band(c, 0xF0)
    local m1 = bit.lshift(bit.band(c, 0x0F), 4)
    send({m0,m1}, true)
end

function send(vals, rs)
    if type(vals) ~= "table" then vals = {vals} end
    local blBit = backlight and const["BACKLIGHT"] or const["NOBACKLIGHT"]
    local rsBit = rs and const["RsBit"] or 0x00

    local debStr = string.format("snd (%i):", #vals)
    for i = 1, #vals do
        debStr = string.format("%s 0x%02X |", debStr, vals[i])
    end
    print(debStr)
    
    local tbl = { 0x00 } -- TODO, might not be necisary, use '{ }' instead
    for i = 1, #vals do
        local payl = bit.bor(vals[i], blBit, rsBit)
        table.insert(tbl, bit.bor(payl, const["EnBit"]))
        table.insert(tbl, payl)
    end
    i2cw(tbl)
end

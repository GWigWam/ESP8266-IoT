-- lcd1602.lua by GWigWam
dofile("lcd1602_const.lua");
print "'lcd1602.lua'"

backlight = true

function begin() -- As specified on page 46 of HD44780U specsheet
    send(0x30) -- set 8bit interface
    tmr.delay(4500)  -- 4.1ms
    send(0x30)
    tmr.delay(4500)
    send(0x30)
    tmr.delay(120) -- 100ns

    local func = bit.bor(LCD_4BITMODE, LCD_2LINE, LCD_5x8DOTS)
    local cntr = bit.bor(LCD_DISPLAYON, LCD_CURSORON, LCD_BLINKON)    
    local mode = bit.bor(LCD_ENTRYLEFT, LCD_ENTRYSHIFTDECREMENT)

    send({ bit.bor(LCD_FUNCTIONSET, LCD_4BITMODE) }) -- Set 4-bit mode
    send({ LCD_FUNCTIONSET, bit.lshift(func, 4) }) -- Function set (NoLines, Font)
    send({ 0x00, bit.lshift(bit.bor(LCD_DISPLAYCONTROL, cntr), 4) }) -- Control set (On/off, Cursor, Blink)
    clear()
    send({ 0x00, bit.lshift(bit.bor(LCD_ENTRYMODESET, mode), 4) }) --Entry mode set (Align, Disp. shift)
    
    tmr.delay(2000)
end

function clear()
    send({0x00, bit.lshift(LCD_CLEARDISPLAY, 4)})
    tmr.delay(2000)
end

function setCursor(col, row)
    local row_offsets = { 0x00, 0x40 }
    local offset = row_offsets[row + 1]
    send({ bit.bor(LCD_SETDDRAMADDR, offset), bit.lshift(col, 4) })
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
    local blBit = backlight and LCD_BACKLIGHT or LCD_NOBACKLIGHT
    local rsBit = rs and RsBit or 0x00

    local debStr = string.format("snd (%i):", #vals)
    for i = 1, #vals do
        debStr = string.format("%s 0x%02X |", debStr, vals[i])
    end
    print(debStr)
    
    local tbl = { 0x00 } -- TODO, might not be necisary, use '{ }' instead
    for i = 1, #vals do
        local payl = bit.bor(vals[i], blBit, rsBit)
        table.insert(tbl, bit.bor(payl, EnBit))
        table.insert(tbl, payl)
    end
    i2cw(tbl)
end

-- lcd1602_const.lua by GWigWam
print "'lcd1602_const.lua'"
return {
    -- Commands
    ["CLEARDISPLAY"]    = 0x01,
    ["RETURNHOME"]      = 0x02,
    ["ENTRYMODESET"]    = 0x04,
    ["DISPLAYCONTROL"]  = 0x08,
    ["CURSORSHIFT"]     = 0x10,
    ["FUNCTIONSET"]     = 0x20,
    ["SETCGRAMADDR"]    = 0x40,
    ["SETDDRAMADDR"]    = 0x80,

    -- flags for display entry mode
    ["ENTRYLEFT"]           = 0x02,
    ["ENTRYRIGHT"]          = 0x00,
    ["ENTRYSHIFTINCREMENT"] = 0x01,
    ["ENTRYSHIFTDECREMENT"] = 0x00,

    -- Flags for display on/off control
    ["DISPLAYON"]  = 0x04,
    ["DISPLAYOFF"] = 0x00,
    ["CURSORON"]   = 0x02,
    ["CURSOROFF"]  = 0x00,
    ["BLINKON"]    = 0x01,
    ["BLINKOFF"]   = 0x00,

    -- Flags for function set
    ["2LINE"]    = 0x08,
    ["1LINE"]    = 0x00,
    ["5x10DOTS"] = 0x04,
    ["5x8DOTS"]  = 0x00,

    ["4BITMODE"] = 0x00,
    ["8BITMODE"] = 0x10,

    -- Backlight
    ["BACKLIGHT"]   = 0x08,
    ["NOBACKLIGHT"] = 0x00,

    ["EnBit"] = 0x04, -- 00000100 Enable bit (Starts read/write)
    ["RwBit"] = 0x02, -- 00000010 Read/Write bit (0: Write, 1: Read)
    ["RsBit"] = 0x01, -- 00000001 Register select bit (0: Instruction register, 1: Data register)
}

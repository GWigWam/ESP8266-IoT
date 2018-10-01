-- lcd1602_const.lua by GWigWam
print "'lcd1602_const.lua'"
return {
    ["SCREENWIDTH"]         = 128,  -- Screen width in px
    ["SCREENHEIGHT"]        = 64,   -- Screen height in px
    ["PIXELCOUNT"]          = 8192, -- (WIDTH * HEIGHT) = (128 * 64)
    ["SEGMENTSIZE"]         = 8,    -- Segement size in px (1 px == 1 bit, 1 segment == 1 byte)
    ["PAGECOUNT"]           = 8,    -- A page is a row of adjacent segments
    ["SEGMENTCOUNT"]        = 1024, -- (PAGECOUNT * SCREENWIDTH) = (8 * 128)
    
    -- Commands
    ["DISPLAYON"]           = 0xAF,
    ["DISPLAYOFF"]          = 0xAE,
    
    ["DISPLAYNORMAL"]       = 0xA6,
    ["DISPLAYINVERSE"]      = 0xA7,

    ["DISPLAYRAMON"]        = 0xA4,
    ["DISPLAYRAMOFF"]       = 0xA5,
    
    ["SETCONTRAST"]         = 0x81,
    ["SETMULTIPLEXRATIO"]   = 0xA8,
    ["SETDISPLAYOFFSET"]    = 0xD3,
    ["SETSTARTLINE"]        = 0x40,
    ["SETCOLADR"]           = 0x21,
    ["SETPAGEADR"]          = 0x22,
    
    ["SETDISPLAYCLOCKDIV"]  = 0xD5,
    ["DISPLAYCLOCKDIV_DEF"] = 0x80,

    ["SETSEGMENTMAP_0"]     = 0xA0,
    ["SETSEGMENTMAP_127"]   = 0xA1,

    ["SETCOMSCANDIR_DEF"]   = 0xC0,
    ["SETCOMSCANDIR_REV"]   = 0xC8,

    ["SETCOMPINS"]          = 0xDA,
    ["COMPINS_DEF"]         = 0x12,

    ["SETPRECHARGE"]        = 0xD9,
    ["PRECHARGE_DEF"]       = 0x22,

    ["SETVCOMDETECT"]       = 0xDB,
    ["VCOMDETECT_DEF"]      = 0x40,

    ["DEACTIVATE_SCROLL"]   = 0x2E,

    ["SETCHARGEPUMP"]       = 0x8D,
    ["CHARGEPUMP"] = {
        ["OFF"]             = 0x10,
        ["ON"]              = 0x14,
    },

    ["SETMEMADRMODE"]       = 0x20,
    ["MEMADRMODE"] = {
        ["HORIZONTAL"]      = 0x00,
        ["VERTICAL"]        = 0x01,
        ["PAGE"]            = 0x02,
    },
}

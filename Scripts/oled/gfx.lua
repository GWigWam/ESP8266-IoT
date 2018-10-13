print("'gfx.lua'")
local this = {}

-- Scale a 8x8 img
this.scale = function(vals, scale)
    if #vals ~= 8 then error('Vals must be table w/ 8 1-byte values') end
    local res = { }
    for inpX=0,7 do
        local curByte = vals[inpX + 1]
        for inpY=0,7 do
            local mask = bit.lshift(1, inpY)
            local curBit = bit.band(curByte, mask) > 0 and 1 or 0
            
            local resY0 = scale * inpY
            for yOfs=0, scale-1 do
                local resY = resY0 + yOfs -- target pixel Y
                
                local byteNr = math.floor(resY / 8) -- target byte Y
                local resIx = (byteNr * scale * 8) + (inpX * scale) + 1 -- index of target byte in res table
                
                local bitNr = resY % 8 -- target bit nr (n-th bit within target byte)
                local newVal = bit.bor(res[resIx] or 0x00, bit.lshift(curBit, bitNr))
                
                for xOfs=0,scale-1 do
                    res[resIx + xOfs] = newVal
                end
            end
        end
    end    
    return res
end

this.iterStr = function(str)
    local font = require('gfx_font')
    local ix = 0
    return function()
        ix = ix + 1
        if ix <= #str then
            local char = str:sub(ix,ix)
            local res = font[char]
            return res
        end
    end
end

this.iterWriteStr = function(str, scale, x, y, xMax, yMax)
    local oled = require('SSD1306')
    local x1, y1, x2, y2 = x, y, 0, 0
    local wdth, hght = (8 * scale), scale
    local strIter = this.iterStr(str)
    return function()
        local c = strIter()
        if c then
            c = this.scale(c, scale)
            x2 = x1 + wdth - 1
            y2 = y1 + hght - 1
            
            return function()
                oled:writeAt(c, x1, y1, x2, y2)        
                x1 = x1 + wdth
                if x1 + wdth > ((xMax or 128) + 1) then
                    x1 = x
                    y1 = y1 + hght
                    if y1 + hght > ((yMax or 7) + 1) then
                        y1 = y
                    end
                end
            end
        end
    end
end

return this

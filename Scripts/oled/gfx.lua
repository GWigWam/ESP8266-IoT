local this = {}

-- Scale a 8x8 img
local scale = function(vals, scale)
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

this.scale = scale
return this

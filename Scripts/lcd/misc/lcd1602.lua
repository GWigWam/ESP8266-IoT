-- https://raw.githubusercontent.com/dvv/nodemcu-thingies/master/lcd1602.lua

local _offsets = { [0] = 0x80, 0xC0, 0x90, 0xD0 } -- 16x4

-- write byte helper
local w = function(self, b, mode)
  i2c.start(0)
  i2c.address(0, self._adr, i2c.TRANSMITTER)
  local bh = bit.band(b, 0xF0) + self._ctl + mode
  local bl = bit.lshift(bit.band(b, 0x0F), 4) + self._ctl + mode
  i2c.write(0, bh + 4, bh, bl + 4, bl)
  i2c.stop(0)
end

-- backlight on/off
local light = function(self, on)
  self._ctl = on and 0x08 or 0x00
  w(self, 0x00, 0)
end

-- clear screen
local clear = function(self)
  w(self, 0x01, 0)
end

-- return command to set cursor at row/col
local locate = function(self, row, col)
  return col + _offsets[row]
end

-- define custom char 0-7
-- NB: e.g. use "\003" in argument to .put to display custom char 3
local define_char = function(self, index, bytes)
  w(self, 0x40 + 8 * bit.band(index, 0x07), 0)
  for i = 1, #bytes do w(self, bytes[i], 1) end
end

-- write to lcd
local put = function(self, ...)
  for _, x in ipairs({...}) do
    -- number?
    if type(x) == "number" then
      -- direct command
      w(self, x, 0)
    -- string?
    elseif type(x) == "string" then
      -- treat as data
      for i = 1, #x do w(self, x:byte(i), 1) end
    end
    tmr.delay(800)
  end
end

-- start lcd
local init = function(self)
  w(self, 0x33, 0)
  w(self, 0x32, 0)
  w(self, 0x28, 0)
  w(self, 0x0C, 0)
  w(self, 0x06, 0)
  w(self, 0x01, 0)
  w(self, 0x02, 0)
end

-- instance metatable
local meta = {
  __index = {
    clear = clear,
    define_char = define_char,
    init = init,
    light = light,
    locate = locate,
    put = put,
  },
}

-- create new LCD1602 instance
return function(adr)
  local self = setmetatable({
    _adr = adr or 0x3F,
    _ctl = 0x08,
  }, meta)
  self:init()
  return self
end

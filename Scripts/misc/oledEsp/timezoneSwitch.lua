print("'timezoneSwitch.lua'")

local this = {
    ["pin"] = nil
}

this.getOffset = function()
    gpio.mode(this.pin, gpio.INPUT, gpio.PULLUP)
    local on = gpio.read(this.pin)
    gpio.mode(this.pin, gpio.INPUT, gpio.FLOAT)
    return on
end

local ctor = function(pin)
    this.pin = pin
    return this
end

return ctor

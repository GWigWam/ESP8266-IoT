print("'leds.lua'")

lRed = 5
lGrn = 7
lLeds = {lGrn,lRed}
table.foreach(lLeds,function(k,v)
    gpio.mode(v,gpio.OUTPUT)
    gpio.write(v,gpio.LOW)
end)

function flash(led, durationMs)
    gpio.write(led, gpio.HIGH)
    tmrDelay(durationMs, function()
        gpio.write(led, gpio.LOW)
    end)
end

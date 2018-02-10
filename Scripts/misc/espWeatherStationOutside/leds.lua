print("'leds.lua'")

lGrn = 1
lRed = 2
lBlu = 3
lLeds = {lGrn,lRed,lBlu}
table.foreach(lLeds,function(k,v)
    gpio.mode(v,gpio.OUTPUT)
    gpio.write(v,gpio.LOW)
end)

function flash(led, durationMs)
    table.foreach(lLeds,function(k,v)
        if v == led then gpio.write(v,gpio.HIGH) else gpio.write(v,gpio.LOW)end
    end)
    tmrDelay(durationMs, function()
        gpio.write(led,gpio.LOW)
    end)
end

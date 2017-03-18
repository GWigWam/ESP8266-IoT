print("init 'leds.lua'")

lGrn = 1
lRed = 2

gpio.mode(lGrn,gpio.OUTPUT)
gpio.mode(lRed,gpio.OUTPUT)

function flash(led, durationMs)
    gpio.write(led,gpio.HIGH)
    tmr.create():alarm(durationMs, tmr.ALARM_SINGLE, function()
        gpio.write(led,gpio.LOW)
    end)
end
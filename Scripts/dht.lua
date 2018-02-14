dhtPin = -1
dhtPwrPin = -1

function initDHT(dataPin, pwrPin)
    dhtPin = dataPin
    dhtPwrPin = pwrPin
    gpio.mode(dhtPwrPin,gpio.OUTPUT)
    gpio.write(dhtPwrPin,gpio.HIGH)
end

function getDHTStats()
    status, temp, humi, temp_dec, humi_dec = dht.read(dhtPin)
    if status == dht.OK then
        return true, temp, humi
    else
        restartDHT()
        return false, -999, -999
    end 
end

function restartDHT()
    gpio.write(dhtPwrPin,gpio.LOW)
    tmrDelay(1000,function() gpio.write(dhtPwrPin,gpio.HIGH) end)
end

dhtPin = 4
function getDHTStats()
    status, temp, humi, temp_dec, humi_dec = dht.read(dhtPin)
    if status == dht.OK then
        return true, temp, humi
    else
        if status == dht.ERROR_CHECKSUM then
            log("DHT Checksum error.")
        elseif status == dht.ERROR_TIMEOUT then
            log("DHT timed out.")
        end
        flash(lRed,1000)
        return false, -999, -999
    end 
end
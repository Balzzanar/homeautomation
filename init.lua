-- Default the mains pin to low!
gpio.write(0, gpio.LOW)

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        -- The actual application is stored in 'application.lua'
        print("-- IP addr --")
        print(wifi.sta.getip())
        dofile("application.lua")
    end
end

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)

-- Read the wifi password from file.
dofile("credentials.lua")
wifi.sta.config(WIFI_SSID, WIFI_PW)

tmr.create():alarm(1000, tmr.ALARM_AUTO, function(cb_timer)
    if wifi.sta.getip() == nil then
        print("Waiting for IP address...")
    else
        cb_timer:unregister()
        print("WiFi connection established, IP address: " .. wifi.sta.getip())
        print("You have 3 seconds to abort")
        print("Waiting...")
        tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
    end
end)

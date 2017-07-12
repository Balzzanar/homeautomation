--                     --
--      Constants      --
--                     --
GPIO_MAIN_CONTROL_ON = false
GPIO_MAIN_CONTROL_PIN = 0
UNIQUE_CLIENT_ID = "ESP001" 
MQTT_TOPIC_STATUS = UNIQUE_CLIENT_ID .. "-status" 
MQTT_TOPIC_CMD = UNIQUE_CLIENT_ID .. "-cmd"
MQTT_CMD_OPTION_ON = "1" 
MQTT_CMD_OPTION_OFF = "0"

--                     --
--      Functions      --
--                     --
function toggleRelay()
    print("toggle")
    if (GPIO_MAIN_CONTROL_PIN)then
        gpio.write(GPIO_MAIN_CONTROL_PIN, gpio.HIGH)
        GPIO_MAIN_CONTROL_ON = true
    else
        gpio.write(GPIO_MAIN_CONTROL_PIN, gpio.LOW)
        GPIO_MAIN_CONTROL_ON = false
    end
end

function setRelay(status)
    -- true == on, false == off
    if (status)then
        gpio.write(GPIO_MAIN_CONTROL_PIN, gpio.HIGH)
        GPIO_MAIN_CONTROL_ON = true
    else 
        gpio.write(GPIO_MAIN_CONTROL_PIN, gpio.LOW)
        GPIO_MAIN_CONTROL_ON = false
    end 
end

--                       --
--      Main Script      --
--                       --

-- Initiate the mqtt client and set keepalive timer to 120sec
-- Think password can be skipped, need to test that.
mqttClient = mqtt.Client("client_id", 120, "username", "password")

mqttClient:on("connect", function(con) print ("connected") end)
mqttClient:on("offline", function(con) print ("offline") end)

-- On receive message
mqttClient:on("message", function(conn, topic, data)
  print(topic .. ":" )
  if (data ~= nil) then
    
    if (topic == MQTT_TOPIC_STATUS and data == "ping") then
        mqttClient:publish(MQTT_TOPIC_STATUS, "pong", 0, 0, function(conn) 
            print("sent response") 
        end)

    elseif (topic == MQTT_TOPIC_CMD) then
            if (data == "0") then
                setRelay(false)
                print("off") 
            elseif (data == "1") then
                print("on") 
                setRelay(true)
            end    
        end
    end

end)


mqttClient:connect("192.168.178.32", 1883, 0, function(conn) 
    print("connected")
    mqttClient:subscribe(MQTT_TOPIC_STATUS, 0, function(conn) 
    -- Handle status
  end)  
    mqttClient:subscribe(MQTT_TOPIC_CMD, 0, function(conn) 
    -- Handle cmd
  end)  
end,
function(client, reason)
    print(reason)
    end)

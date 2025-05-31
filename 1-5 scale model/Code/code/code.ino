#include <FastLED.h>
#include <ESP32Servo.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>

#include <WiFi.h>
#include <WebServer.h>
#include <WiFiMulti.h>
#include <ESPmDNS.h>
WebServer server(80); // Define server for ESP32
WiFiMulti WiFiMulti;  // Define WiFiMulti for ESP32

WebSocketsServer webSocket = WebSocketsServer(81);

// Start mDNS service
String hostname = "joystick";

int SteerFLPin = 1;
int SteerFRPin = 2;
int SteerBLPin = 3;
int SteerBRPin = 4;

Servo servoFL;
Servo servoFR;
Servo servoBL;
Servo servoBR;

int YawPin = 6;
int PitchPin = 5;
int ElbowPin = 8;

Servo servoYaw;
Servo servoPitch;
Servo servoElbow;

int IN1Pin = 13;
int IN2Pin = 12;
int ENAPin = 11;
int speed = 0; // [0, 255] for L298N EN input

const char index_html[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ESP8266/32 Joystick Control</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: top;
            height: 100vh;
            margin: 2px;
            padding: 5px;
            background-color: #f0f0f0;
            box-sizing: border-box;
        }

        .container {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 5px; /* Increased gap for better spacing */
            padding: 0px 15px 0px 15px; /* Add padding for inner spacing */
            background: linear-gradient(135deg, #f0f0f0, #e0e0e0); /* Gradient background */
            border: 1px solid #ccc; /* Subtle border */
            border-radius: 15px; /* Rounded corners */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Subtle shadow */
            margin: 10px auto; /* Center the container with margin */
            max-width: 95%; /* Responsive width */
        }

        .joystick-container {
            position: relative;
            width: 250px;
            height: 250px;
            background: radial-gradient(circle, #f0f0f0, #ccc); /* Gradient background */
            border-radius: 50%;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2); /* Subtle shadow */
            border: 1px solid #bbb; /* Border for a more defined look */
            display: flex;
            justify-content: center;
            align-items: center;
        }     

        .joystick-container::before,
        .joystick-container::after {
            content: '';
            position: absolute;
            background-color: #cfcfcf; /* Line color */
        }

        .joystick-container::before {
            width: 1px; /* Line thickness */
            height: 100%;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
        }

        .joystick-container::after {
            width: 100%;
            height: 1px; /* Line thickness */
            top: 50%;
            left: 0;
            transform: translateY(-50%);
        }

        .joystick {
            position: absolute;
            width: 50px;
            height: 50px;
            background: radial-gradient(circle, #007bff, #0056b3); /* Gradient background */
            border-radius: 50%;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2); /* Subtle shadow */
            touch-action: none;
            border: 2px solid #004080; /* Border for a more defined look */
            z-index: 1;
        }

        .joystick::before {
            content: '';
            position: absolute;
            width: 10px; /* Size of the red dot */
            height: 10px; /* Size of the red dot */
            background-color: rgb(121, 25, 25);
            border-radius: 50%;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2); /* Subtle shadow for the dot */
        }

        .sliders {
            display: flex;
            flex-direction: column; /* Align sliders vertically */
            justify-content: center;
            align-items: center;
            padding: 10px; /* Add padding to all sides */
            gap: 10px; /* Add space between sliders */
        }
        .slider-container {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .slider {
            -webkit-appearance: none; /* Override default CSS styles */
            appearance: none;
            width: 300px; /* Full width */
            height: 15px; /* Height of the slider */
            background: linear-gradient(to right, green, red); /* Gradient background */
            outline: none; /* Remove outline */
            opacity: 0.7; /* Set transparency */
            transition: opacity .2s; /* Transition effect */
            border-radius: 10px; /* Rounded edges */
            /* transform: rotate(-90deg); Rotate the slider */
        }
        .slider:hover {
            opacity: 1; /* Fully opaque on hover */
        }
        .slider::-webkit-slider-thumb {
            -webkit-appearance: none; /* Override default CSS styles */
            appearance: none;
            width: 25px; /* Width of the thumb */
            height: 25px; /* Height of the thumb */
            background: #4CAF50; /* Green background */
            cursor: pointer; /* Cursor on hover */
            border-radius: 5px; /* Rounded edges */
        }
        .slider::-moz-range-thumb {
            width: 25px; /* Width of the thumb */
            height: 30px; /* Height of the thumb */
            background: #4CAF50; /* Green background */
            cursor: pointer; /* Cursor on hover */
            border-radius: 5px; /* Rounded edges */
        }

        .buttons {
            display: flex;
            justify-content: space-around;
            width: 330px;
            flex-wrap: wrap;
        }

        .button {
            width: 100px;
            height: 60px;
            background-color: #28a745;
            border: none;
            color: white;
            font-size: 16px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            cursor: pointer;
            transition: background-color 0.3s ease;
            margin: 5px;
            user-select: none; /* Prevent text selection */
        }

        .button.switch-on {
            background-color: #ff0707;
        }

        .button.push-active {
            background-color: #0056b3;
            user-select: none; /* Prevent text selection */
        }
        .common-label {
            font-size: 16px;
            font-weight: bold;
            margin-right: 1px;
            color: #333;
        }

        .toggle-checkbox {
            width: 20px;
            height: 20px;
            cursor: pointer;
            accent-color: #007bff; /* Change the color of the checkbox */
        }
        .check-button-container {
            display: flex;
            justify-content: left;
            width: 100%;
            align-items: center;
            gap: 5px;
        }
        .status-label {
            font-size: 14px;
            font-weight: bold;
            padding: 5px 10px;
            border-radius: 5px;
            color: #fff;
        }

        .status-connected {
            background-color: #28a745; /* Green background for connected */
        }

        .status-disconnected {
            background-color: #dc3545; /* Red background for disconnected */
        }
    </style>
</head>
<body>
    <div class="container">
        <div id="status" class="status-label status-disconnected">Disconnected</div>
        </div>
        
        <div>
        <u>Movement</u>
        </div>
        
        <div class="check-button-container">
            <label class="common-label" for="toggle-return">RTH:</label>
            <input class="toggle-checkbox" type="checkbox" id="toggle-return" checked onchange="handleToggleChange()">
            <label class="common-label" for="toggle-sl">SL:</label>
            <input class="toggle-checkbox" type="checkbox" id="toggle-sl" unchecked onchange="handleSL()">

        </div>
        <div class="joystick-container">
            <div class="joystick" id="joystick"></div>
        </div>

        <div class="sliders">
            <div class="slider-container">
                <label class="common-label" id="labelSpeedSlider" for="speedSlider">Speed Slider: 0</label>
                <input type="range" id="speedSlider" class="slider" min="0" max="100" value="0" onchange="sendSpeedSliderData()">
            </div>
        </div>
        
        <div>
        <u>Crane</u>
        </div>
        
        <div class="sliders">
            <div class="slider-container">
                <label class="common-label" id="labelYawSlider" for="yawSlider">Yaw Slider: 0</label>
                <input type="range" id="yawSlider" class="slider" min="0" max="100" value="0" onchange="sendYawSliderData()">
            </div>
            <div class="slider-container">
                <label class="common-label" id="labelPitchSlider" for="pitchSlider">Pitch Slider: 0</label>
                <input type="range" id="pitchSlider" class="slider" min="0" max="100" value="0" onchange="sendPitchSliderData()">
            </div>
        </div>

        <div class="buttons">
            <button id="ExtensionCCW" class="button" onmousedown="sendPushData(1, 1)" onmouseup="sendPushData(1, 0)" ontouchstart="sendPushData(1, 1)" ontouchend="sendPushData(1, 0)">Extension CCW</button>
            <button id="ExtensionCW" class="button" onmousedown="sendPushData(2, 1)" onmouseup="sendPushData(2, 0)" ontouchstart="sendPushData(2, 1)" ontouchend="sendPushData(2, 0)">Extension CW</button>
        </div>
        
        <div class="sliders">
            <div class="slider-container">
                <label class="common-label" id="labelElbowSlider" for="elbowSlider">Elbow Slider: 0</label>
                <input type="range" id="elbowSlider" class="slider" min="0" max="100" value="0" onchange="sendElbowSliderData()">
            </div>
        </div>
    </div>

    <script>
        const joystick = document.getElementById('joystick');
        const joystickContainer = document.querySelector('.joystick-container');
        const slider1 = document.getElementById('slider1');
        const slider2 = document.getElementById('slider2');
        const toggleReturn = document.getElementById('toggle-return');
        const statusLabel = document.getElementById('status');
        
        let joystickOffset = { x: 0, y: 0 };
        let isDragging = false;
        let xPos = 0;
        let yPos = 0;

        let socket;

        // Initialize WebSocket
        function initWebSocket() {
            socket = new WebSocket('ws://' + location.hostname + ':81'); // Replace with your server's IP and port

            socket.onopen = function() {
                console.log("WebSocket connection opened");
                updateStatus(true);
            };

            socket.onmessage = function(event) {
                console.log("Message from server: ", event.data);
            };

            socket.onclose = function() {
                console.log("WebSocket connection closed");
                updateStatus(false);
            };

            socket.onerror = function(error) {
                console.error("WebSocket error: ", error);
                updateStatus(false);
            };
        }

        // Send joystick position
        function sendJoystickData(x, y) {
            const data = JSON.stringify({ type: 'joystick', x: Math.round(x*125), y: Math.round(y*(-125)) });
            socket.send(data);
        }

        // Send slider data
        function sendSpeedSliderData() {
            const data = JSON.stringify({ speedSlider: speedSlider.value });
            document.getElementById('labelSpeedSlider').innerHTML = "Speed Slider: " + speedSlider.value;
            socket.send(data);
        }

        function sendYawSliderData() {
            const data = JSON.stringify({ yawSlider: yawSlider.value });
            document.getElementById('labelYawSlider').innerHTML = "Yaw Slider: " + yawSlider.value;
            socket.send(data);
        }
        
        function sendPitchSliderData() {
            const data = JSON.stringify({ pitchSlider: pitchSlider.value });
            document.getElementById('labelPitchSlider').innerHTML = "Pitch Slider: " + pitchSlider.value;
            socket.send(data);
        }
        
        function sendElbowSliderData() {
            const data = JSON.stringify({ elbowSlider: elbowSlider.value });
            document.getElementById('labelElbowSlider').innerHTML = "Elbow Slider: " + elbowSlider.value;
            socket.send(data);
        }

        function initSliders() {
            // initialize the sliders to 0
            document.getElementById('speedSlider').value = 0;
            document.getElementById('yawSlider').value = 0;
            document.getElementById('pitchSlider').value = 0;
            document.getElementById('elbowSlider').value = 0;
        }
        initSliders();

        // Toggle switch
        function toggleSwitch(id) {
            const button = document.getElementById('switch' + id);
            const isOn = button.classList.toggle('switch-on');  // Toggle switch status
            const value = isOn ? 1 : 0;
            const data = JSON.stringify({ type: 'switch', id: id, value: value });
            socket.send(data);
        }

        // Send push button data
        function sendPushData(id, value) {
            const button = document.getElementById('push' + id);
            const data = JSON.stringify({ type: 'push', id: id, value: value });
            socket.send(data);

            // Add visual effect on press
            if (value === 1) {
                button.classList.add('push-active');
            } else {
                button.classList.remove('push-active');
            }
        }

        // Joystick drag and reset
        joystick.addEventListener('mousedown', startDrag);
        joystick.addEventListener('touchstart', startDrag, { passive: true });

        
        function startDrag(event) {
            event.preventDefault();
            isDragging = true;

            document.addEventListener('mousemove', dragJoystick);
            document.addEventListener('mouseup', stopDrag);
            document.addEventListener('touchmove', dragJoystick, { passive: true });
            document.addEventListener('touchend', stopDrag);

            const rect = joystickContainer.getBoundingClientRect();

            if (event.touches) {
                joystickOffset.x = event.touches[0].clientX - rect.left - xPos;
                joystickOffset.y = event.touches[0].clientY - rect.top - yPos;
            } else {
                joystickOffset.x = event.clientX - rect.left - xPos;
                joystickOffset.y = event.clientY - rect.top - yPos;
            }
        }

        function dragJoystick(event) {
            if (!isDragging) return;

            const rect = joystickContainer.getBoundingClientRect();
            const limitRadius = rect.width / 2 - joystick.offsetWidth / 2;

            if (event.touches) {
                xPos = event.touches[0].clientX - rect.left - joystickOffset.x;
                yPos = event.touches[0].clientY - rect.top - joystickOffset.y;
            } else {
                xPos = event.clientX - rect.left - joystickOffset.x;
                yPos = event.clientY - rect.top - joystickOffset.y;
            }

            const distance = Math.sqrt(xPos * xPos + yPos * yPos);
            if (distance > limitRadius) {
                const angle = Math.atan2(yPos, xPos);
                xPos = limitRadius * Math.cos(angle);
                yPos = limitRadius * Math.sin(angle);
            }

            joystick.style.left = `${xPos + rect.width / 2}px`;
            joystick.style.top = `${yPos + rect.height / 2}px`;

            // Send joystick data to server
            sendJoystickData(xPos / limitRadius, yPos / limitRadius);
        }

        function stopDrag() {
            isDragging = false;
            document.removeEventListener('mousemove', dragJoystick);
            document.removeEventListener('mouseup', stopDrag);
            document.removeEventListener('touchmove', dragJoystick);
            document.removeEventListener('touchend', stopDrag);

            if (toggleReturn.checked) {
                sendJoystickData(0, 0);
                xPos = 0;
                yPos = 0;
                joystick.style.left = '50%';
                joystick.style.top = '50%';
            }
        }
        function updateStatus(isConnected) {
            if (isConnected) {
                statusLabel.textContent = 'Connected';
                statusLabel.classList.remove('status-disconnected');
                statusLabel.classList.add('status-connected');
            } else {
                statusLabel.textContent = 'Disconnected';
                statusLabel.classList.remove('status-connected');
                statusLabel.classList.add('status-disconnected');
            }
        }
        function handleToggleChange() {
            if (toggleReturn.checked) {
                sendJoystickData(0, 0);
                xPos = 0;
                yPos = 0;
                joystick.style.left = '50%';
                joystick.style.top = '50%';
            } else {
                console.log('Return to Home is disabled');
                // Add your logic here for when the checkbox is unchecked
            }
        }

        function handleSL() {
            // make the container unscrollable when the checkbox is checked
            if (document.getElementById('toggle-sl').checked) {
                // disable touch action of container
                document.querySelector('.container').style.touchAction = 'none';
            } else {
                // enable touch action of container
                document.querySelector('.container').style.touchAction = 'auto';
            }
        }

        window.onload = initWebSocket;
    </script>
</body>

// </html>
// )rawliteral";

const float MAX_TURN_ANGLE = 45.0;

void setSteeringServoAngles(float fl, float fr, float bl, float br) {
    servoFL.write(map(fl, -MAX_TURN_ANGLE, MAX_TURN_ANGLE, 0, 180));
    servoFR.write(map(fr, -MAX_TURN_ANGLE, MAX_TURN_ANGLE, 0, 180));
    servoBL.write(map(bl, -MAX_TURN_ANGLE, MAX_TURN_ANGLE, 0, 180));
    servoBR.write(map(br, -MAX_TURN_ANGLE, MAX_TURN_ANGLE, 0, 180));
}

void moveRover(int x, int y, int inputSpeed){
    // Expects x, y to be [-125, 125]
    // Expects inputSpeed to be [0, 255]

    ////// Determine Steering Pointing //////
    // Normalize x and y to [-1, 1]
    float xNorm = x / 125.0;
    float yNorm = y / 125.0;

    // Avoid division by zero
    if (abs(xNorm) < 0.01 && abs(yNorm) < 0.01) {
        // Set all angles to 0 (straight)
        setSteeringServoAngles(0, 0, 0, 0);
    } else {
        // Define a target point (ICR) based on joystick
        // Map xNorm to an angle between -MAX_TURN_ANGLE and MAX_TURN_ANGLE
        float turnAngle = atan2(xNorm, yNorm) * 180.0 / PI;
        turnAngle = constrain(turnAngle, -MAX_TURN_ANGLE, MAX_TURN_ANGLE);
        setSteeringServoAngles(turnAngle, turnAngle, turnAngle, turnAngle);
    }

    ////// Determine Motor Speed and Direction //////
    double speedMultiple = inputSpeed/255;
    double joyStickSpeed = map(abs(y), 0, 125, 0, 255);
    int speed = (int)(joyStickSpeed * speedMultiple); // [0, 255]
    analogWrite(ENAPin, speed);

    if(y > 0){
        // Move Forward
        digitalWrite(IN1Pin, HIGH);
        digitalWrite(IN2Pin, LOW);
    } else {
        // Move Backward
        digitalWrite(IN1Pin, LOW);
        digitalWrite(IN2Pin, HIGH);
    }
}

void handleRoot() {
  server.send(200, "text/html", index_html);
}

void handleWebSocketMessage(uint8_t *data, size_t len, uint8_t num)
{
    // Allocate the JSON document
    StaticJsonDocument<200> doc;

    // Deserialize the JSON document
    DeserializationError error = deserializeJson(doc, data, len);

    // Test if parsing succeeds
    if (error)
    {
        Serial.print(F("deserializeJson() failed: "));
        Serial.println(error.f_str());
        return;
    }

    // Handle the received data based on type
    if (doc["type"] == "joystick")
    {
        int x = doc["x"].as<int>();
        int y = doc["y"].as<int>();
        moveRover(x, y, speed);
    }
    else if (doc["speedSlider"].as<int>() >= 0)
    {
        int speedValue = doc["speedSlider"].as<int>();
        speed = map(speedValue, 0, 100, 0, 255);
    }
    else if (doc["yawSlider"].as<int>() >= 0)
    {
        int yawValue = doc["yawSlider"].as<int>();
        int yaw = map(yawValue, 0, 100, 0, 180);
        servoYaw.write(yaw);
    }
    else if (doc["pitchSlider"].as<int>() >= 0)
    {
        int pitchValue = doc["pitchSlider"].as<int>();
        int pitch = map(pitchValue, 0, 100, 0, 180);
        servoPitch.write(pitch);
    }
    else if (doc["elbowSlider"].as<int>() >= 0)
    {
        int elbowValue = doc["elbowSlider"].as<int>();
        int elbow = map(elbowValue, 0, 100, 0, 180);
        servoElbow.write(elbow);
    }
    // else if (doc["type"] == "switch")
    // {
    //     int id = doc["id"].as<int>();
    //     int value = doc["value"].as<int>();
    //     // webSocket.sendTXT(num, "Switch data received: ID: " + String(id) + " Value: " + String(value));
    // }
    else if (doc["type"] == "push")
    {
        int id = doc["id"].as<int>();
        int value = doc["value"].as<int>();
        if(value == 1){
            if(id == 1){
                // TODO extend out 
            }
            else if (value == 2){
                // TODO retract in
            }
        }
    }
    else
    {
        Serial.println("Unknown data received");
        webSocket.sendTXT(num, "Unknown data received");
    }
}

void onWebSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length)
{
    switch (type)
    {
    case WStype_DISCONNECTED:
        Serial.printf("[%u] Disconnected!\n", num);
        break;
    case WStype_CONNECTED:
    {
        IPAddress ip = webSocket.remoteIP(num);
        Serial.printf("[%u] Connection from ", num);
        Serial.println(ip.toString());
        break;
    }
    case WStype_TEXT:
        //webSocket.sendTXT(num, payload);
        handleWebSocketMessage(payload, length, num);
        break;
    case WStype_BIN:
        Serial.printf("[%u] get binary length: %u\n", num, length);
        break;
    case WStype_PING:
        Serial.printf("[%u] Received PING\n", num);
        break;
    case WStype_PONG:
        Serial.printf("[%u] Received PONG\n", num);
        break;
    case WStype_ERROR:
        Serial.printf("[%u] WebSocket Error!\n", num);
        break;
    }
}

void setup() {
  Serial.begin(115200);
  Serial.println("Entering Setup");

  // Set up AP mode
  WiFi.softAP("Joystick", "password123"); // Set your AP SSID and password
  IPAddress myIP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(myIP);

  // Start the HTTP server
  server.on("/", handleRoot);
  server.begin();
  Serial.println("HTTP server started");

  // Start the WebSocket server
  webSocket.begin();
  webSocket.onEvent(onWebSocketEvent);
  Serial.println("WebSocket server started");

  // Servo Attaches
  servoFL.attach(SteerFLPin);
  servoFR.attach(SteerFRPin);
  servoBL.attach(SteerBLPin);
  servoBR.attach(SteerBRPin);

  servoYaw.attach(YawPin);
  servoPitch.attach(PitchPin);
  servoElbow.attach(ElbowPin);

  // Drive Motor Setup
  pinMode(IN1Pin, OUTPUT);
  pinMode(IN2Pin, OUTPUT);
  pinMode(ENAPin, OUTPUT);

}

void loop() {
  server.handleClient();
  webSocket.loop();
}

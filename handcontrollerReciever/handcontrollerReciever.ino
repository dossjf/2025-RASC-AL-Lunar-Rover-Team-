#include <esp_now.h>
#include <WiFi.h>
#include <ESP32Servo.h>
Servo joint1PitchServo;
Servo joint1YawServo;
Servo joint2PitchServo;
Servo joint2YawServo;
Servo joint3PitchServo;
Servo joint3YawServo;
Servo grabberServo;

float joint1Pitch = 0;
float joint1Yaw = 0;
float joint2Pitch = 0;
float joint2Yaw = 0;
float joint3Pitch = 0;
float joint3Yaw = 0;
float grabberServoAngle = 0;
// Structure example to receive data
// Must match the sender structure
typedef struct struct_message {
  float pitch;
  float yaw;
  int joint;
} struct_message;

int val;
int joint1PitchPin = 21;
int joint1YawPin = 22;
int joint2PitchPin = 19;
int joint2YawPin = 23;
int joint3PitchPin = 18;
int joint3YawPin = 5;
int grabberPin = 17;
// Create a struct_message called myData
struct_message myData;

// callback function that will be executed when data is received
void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len) {
  memcpy(&myData, incomingData, sizeof(myData));
  Serial.print("Pitch: ");
  Serial.println(myData.pitch);

  Serial.print("Yaw: ");
  Serial.println(myData.yaw);

  Serial.print("Joint: ");
  Serial.println(myData.joint);

  Serial.println();
  int joint = myData.joint;
  if(joint == 1) {
    joint1Pitch = myData.pitch;
    joint1Yaw = myData.yaw;
  } else if (joint == 2) {
    joint2Pitch = myData.pitch;
    joint2Yaw = myData.yaw;
  } else if (joint == 3) {
    joint3Pitch = myData.pitch;
    joint3Yaw = myData.yaw;
  } else if (joint == 4) {
    grabberServoAngle = myData.pitch;
  }

  joint1PitchServo.write(map(joint1Pitch, -90, 90, 0, 180));
  joint1YawServo.write(map(joint1Yaw, -90, 90, 0, 180));

  joint2PitchServo.write(map(joint2Pitch, -90, 90, 0, 180));
  joint2YawServo.write(map(joint2Yaw, -90, 90, 0, 180));

  joint3PitchServo.write(map(joint3Pitch, -90, 90, 0, 180));
  joint3YawServo.write(map(joint3Yaw, -90, 90, 0, 180));

  grabberServo.write(map(grabberServoAngle, -90, 90, 0, 180));
  delay(15);
}
 
void setup() {
  // Initialize Serial Monitor
  Serial.begin(115200);
  ESP32PWM::allocateTimer(0);
	ESP32PWM::allocateTimer(1);
	ESP32PWM::allocateTimer(2);
	ESP32PWM::allocateTimer(3);

	joint1PitchServo.setPeriodHertz(50);    // standard 50 hz servo
  joint1YawServo.setPeriodHertz(50);    // standard 50 hz servo
  joint2PitchServo.setPeriodHertz(50);    // standard 50 hz servo
  joint2YawServo.setPeriodHertz(50);    // standard 50 hz servo
  joint3PitchServo.setPeriodHertz(50);    // standard 50 hz servo
  joint3YawServo.setPeriodHertz(50);    // standard 50 hz servo
  grabberServo.setPeriodHertz(50);    // standard 50 hz servo

	joint1PitchServo.attach(joint1PitchPin, 1000, 2000);
  joint1YawServo.attach(joint1YawPin, 1000, 2000);
  joint2PitchServo.attach(joint2PitchPin, 1000, 2000);
  joint2YawServo.attach(joint2YawPin, 1000, 2000);
  joint3PitchServo.attach(joint3PitchPin, 1000, 2000);
  joint3YawServo.attach(joint3YawPin, 1000, 2000);
  grabberServo.attach(grabberPin, 1000, 2000);
  // Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);

  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }
  
  // Once ESPNow is successfully Init, we will register for recv CB to
  // get recv packer info
  esp_now_register_recv_cb(esp_now_recv_cb_t(OnDataRecv));
}
 
void loop() {

}
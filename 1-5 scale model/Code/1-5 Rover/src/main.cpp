#include <Arduino.h>

void setup() {
  Serial.begin(115200);  // Initialize serial with baud rate of 115200
  while (!Serial) {
    ; // Wait for serial port to connect. Needed for native USB
  }
  delay(1000);
  Serial.println("setup");
}

void loop() {
  Serial.println("loop");
  // nothing here for now
}
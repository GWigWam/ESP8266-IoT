#include <Arduino.h>
#include <ESP8266WiFi.h>

#define LED 2

const char* ssid = "<...>";
const char* password = "<...>";

void setup() {
  pinMode(LED, OUTPUT);

  Serial.begin(115200);
  delay(10);
  Serial.println('\n');
  
  WiFi.begin(ssid, password);
  Serial.print("Connecting to ");
  Serial.print(ssid); Serial.println(" ...");

  int i = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(++i); Serial.print(' ');
  }

  Serial.println('\n');
  Serial.println("Connection established!");  
  Serial.print("IP address:\t");
  Serial.println(WiFi.localIP());
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(LED, HIGH);
  Serial.println("LED is off");
  delay(random(100, 1000));
  digitalWrite(LED, LOW);
  Serial.println("LED is on");
  delay(1000);
}

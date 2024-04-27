#include "secret.h" // define SSID / WSEC
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <NTPClient.h>

#define PIN_D1 5
#define PIN_D2 4
#define PIN_D3 0
#define PIN_D4 2

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

WiFiUDP ntpUDP;
const long updInterval = 60 * 60 * 1000;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 0, updInterval);

void showBanner(const __FlashStringHelper* msg, int size) {
  display.clearDisplay();
  display.setTextSize(size);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  display.println(msg);
  display.display();
}

void connectWiFi() {
  WiFi.begin(SSID, WSEC);
  wl_status_t status;
  do {
    delay(100);
    status = WiFi.status();
  } while (status != WL_CONNECTED);
}

int hOffset = 0; // HRS offset from UTC

void setup() {
  Serial.begin(115200);

  Wire.begin(PIN_D2, PIN_D3);
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { 
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }
  display.setTextColor(WHITE);
  display.clearDisplay();
  display.display();
  showBanner(F("Init WiFi"), 2);
  connectWiFi();
  showBanner(F("Connected"), 2);

  timeClient.begin();
  timeClient.update();
  hOffset += 1; // NL UTC+1

  time_t epochTime = timeClient.getEpochTime();
  struct tm *ptm = gmtime((time_t *)&epochTime);
  if(ptm->tm_mon > 2 && ptm->tm_mon < 10) { // Approx
    hOffset += 1; // Summer time
  }

  WiFi.disconnect(true);
}

void loop() {
  //timeClient.update();
  int h = timeClient.getHours() + hOffset;
  int m = timeClient.getMinutes();
  int s = timeClient.getSeconds();

  display.clearDisplay();
  display.setTextSize(3);
  display.setCursor(20,20);

  char text[6];
  sprintf(text, "%02d:%02d", h, m);

  display.println(text);
  display.display();

  int delayS = 60 - s;
  delay(delayS * 1000);
}

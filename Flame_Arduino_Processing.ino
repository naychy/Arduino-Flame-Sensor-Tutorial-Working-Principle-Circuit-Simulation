/*
 * Flame Detection Module  —  Arduino for Processing GUI
 *
 * Copy of Flame_Detection_Module.ino, serial output made for
 * Flame_Circuit_Simulation.pde  (9600 baud).
 *
 * Wire:
 *   VCC -> Arduino 5V
 *   GND -> Arduino GND
 *   AO  -> Arduino A0
 *   DO  -> Arduino D2
 *
 * 1. Upload this sketch.
 * 2. CLOSE Arduino Serial Monitor.
 * 3. Run Flame_Circuit_Simulation in Processing.
 * 4. Click your COM port, then Connect.
 *
 * Line sent every sample:
 *   A:analog,D:doPin,F:flame
 *   A = 0-1023 from A0
 *   D = 0 if DO is LOW, 1 if DO is HIGH
 *   F = 1 flame detected, 0 no flame
 */

const int PIN_AO = A0;
const int PIN_DO = 2;

const unsigned long SAMPLE_MS = 80;

const bool ANALOG_FALLS_WITH_FLAME = true;
const bool DIGITAL_ACTIVE_LOW = true;

const int ANALOG_FLAME_THRESHOLD = 500;
const int ANALOG_CLOSE_THRESHOLD = 250;

int analogValue = 0;
int digitalValue = HIGH;
bool flameDetected = false;

void setup() {
  pinMode(PIN_DO, INPUT);
  Serial.begin(9600);
  delay(300);
}

void loop() {
  analogValue = analogRead(PIN_AO);
  digitalValue = digitalRead(PIN_DO);

  bool analogFlame = ANALOG_FALLS_WITH_FLAME
                       ? (analogValue < ANALOG_FLAME_THRESHOLD)
                       : (analogValue > ANALOG_FLAME_THRESHOLD);

  bool digitalFlame = DIGITAL_ACTIVE_LOW
                        ? (digitalValue == LOW)
                        : (digitalValue == HIGH);

  flameDetected = digitalFlame || analogFlame;

  sendToProcessing();
  delay(SAMPLE_MS);
}

void sendToProcessing() {
  int dPin = (digitalValue == LOW) ? 0 : 1;
  int fFlag = flameDetected ? 1 : 0;

  Serial.print(F("A:"));
  Serial.print(analogValue);
  Serial.print(F(",D:"));
  Serial.print(dPin);
  Serial.print(F(",F:"));
  Serial.println(fFlag);
}

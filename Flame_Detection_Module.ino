    /*
 * Flame Detection Module  —  Arduino tutorial sketch
 *
 * Hardware (4-pin IR flame module, KY-026 style):
 *   VCC -> Arduino 5V
 *   GND -> Arduino GND
 *   AO  -> Arduino A0   (analog intensity)
 *   DO  -> Arduino D2   (digital detect, from LM393)
 *
 * Open: Tools > Serial Monitor  |  baud 9600
 *
 * How it works (short):
 *   Flame emits infrared ~760–1100 nm
 *   YG1006 photodiode resistance drops
 *   AO voltage changes  -> analog number 0–1023
 *   LM393 compares that voltage to the blue potentiometer
 *   DO goes LOW (typical) when flame is over the threshold
 */

const int PIN_AO = A0;
const int PIN_DO = 2;

const unsigned long SAMPLE_MS = 250;

// Most cheap 4-pin modules: analog FALLS when a flame is close.
// Digital DO is usually ACTIVE LOW (0 = flame). Flip these if yours is opposite.
const bool ANALOG_FALLS_WITH_FLAME = true;
const bool DIGITAL_ACTIVE_LOW = true;

const int ANALOG_FLAME_THRESHOLD = 500;   // tune after you watch Serial numbers
const int ANALOG_CLOSE_THRESHOLD = 250;

int analogValue = 0;
int digitalValue = HIGH;
bool flameDetected = false;

void setup() {
  pinMode(PIN_DO, INPUT);
  Serial.begin(9600);

  Serial.println();
  Serial.println(F("================================================"));
  Serial.println(F("  FLAME DETECTION MODULE"));
  Serial.println(F("================================================"));
  Serial.println(F("  Sensor : IR photodiode (YG1006 style)"));
  Serial.println(F("  Chip   : LM393 comparator"));
  Serial.println(F("  Pins   : AO -> A0   DO -> D2   VCC 5V  GND"));
  Serial.println(F("  Baud   : 9600"));
  Serial.println(F("------------------------------------------------"));
  Serial.println(F("  TEST : hold a lighter 10-80 cm in front of"));
  Serial.println(F("         the BLACK photodiode (not the LEDs)."));
  Serial.println(F("         Turn the blue pot to set sensitivity."));
  Serial.println(F("================================================"));
  Serial.println();
  delay(800);
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

  // Digital pin is the LM393 decision. Analog is extra intensity info.
  flameDetected = digitalFlame || analogFlame;

  printSerialBox();
  delay(SAMPLE_MS);
}

void printSerialBox() {
  const char* digitalText = (digitalValue == LOW) ? "LOW " : "HIGH";
  const char* statusText = flameDetected ? "FLAME DETECTED" : "NO FLAME      ";
  const char* distanceText = distanceHint();

  Serial.println(F("================================================"));
  Serial.println(F("  FLAME DETECTION  |  Serial Monitor 9600"));
  Serial.println(F("================================================"));

  Serial.print(F("  Analog AO (A0) : "));
  printPadded(analogValue, 4);
  Serial.print(F("  "));
  printBar(analogValue);
  Serial.println();

  Serial.print(F("  Digital DO (D2): "));
  Serial.print(digitalText);
  Serial.print(F("     (LM393 output)"));
  Serial.println();

  Serial.print(F("  Status         : "));
  Serial.println(statusText);

  Serial.print(F("  Distance hint  : "));
  Serial.println(distanceText);

  Serial.println(F("------------------------------------------------"));
  Serial.print(F("  Plotter line   : Analog:"));
  Serial.print(analogValue);
  Serial.print(F(" Digital:"));
  Serial.println(digitalValue == LOW ? 0 : 1);
  // Compact line for Processing GUI  (A=analog  D=DO pin  F=flame 1/0)
  Serial.print(F("A:"));
  Serial.print(analogValue);
  Serial.print(F(",D:"));
  Serial.print(digitalValue == LOW ? 0 : 1);
  Serial.print(F(",F:"));
  Serial.println(flameDetected ? 1 : 0);
  Serial.println(F("================================================"));
  Serial.println();
}

const char* distanceHint() {
  if (!flameDetected) {
    return "none — no IR flame in view";
  }
  if (ANALOG_FALLS_WITH_FLAME) {
    if (analogValue < ANALOG_CLOSE_THRESHOLD) return "CLOSE  (strong IR)";
    if (analogValue < ANALOG_FLAME_THRESHOLD) return "NEAR   (medium IR)";
    return "FAR    (weak IR)";
  }
  if (analogValue > 800) return "CLOSE  (strong IR)";
  if (analogValue > ANALOG_FLAME_THRESHOLD) return "NEAR   (medium IR)";
  return "FAR    (weak IR)";
}

void printPadded(int value, int width) {
  int digits = 1;
  int n = value;
  while (n >= 10) {
    n /= 10;
    digits++;
  }
  for (int i = digits; i < width; i++) {
    Serial.print(' ');
  }
  Serial.print(value);
}

// 20-block bar of the 0-1023 analog reading
void printBar(int value) {
  int blocks = map(value, 0, 1023, 0, 20);
  Serial.print('[');
  for (int i = 0; i < 20; i++) {
    Serial.print(i < blocks ? '#' : '-');
  }
  Serial.print(']');
}

/**
 * Flame Detection Module � Circuit Simulation
 * Processing 3 / 4
 *
 * LIVE : Arduino Serial 9600  (close Arduino Serial Monitor first)
 * DEMO : click lighter if COM is not connected
 *
 * Sketch ? Import Library ? Serial  if import fails.
 */

import processing.serial.*;

PFont fontTitle, fontUi, fontSmall, fontHuge;
int lastW, lastH;

Serial serial;
String[] ports = new String[0];
int portIndex = 0;
boolean connected = false;
String serialStatus = "Pick COM port, then Connect. Close Serial Monitor first.";

boolean lighterOn = false;
boolean draggingPot = false;

int analogValue = 900;
int digitalOut = 0;
int threshold = 500;
float flowPhase = 0;
float flameFlicker = 0;

int COL_YELLOW, COL_RED, COL_INK, COL_MUTED, COL_CARD, COL_BG, COL_RAIL;

float lightX, lightY, btnX, btnY, btnW, btnH;
float portX, portY, portW, portH, connX, connW;
float vccY, gndY, pdX, aoY, rY, potX, potY;
float chipX, chipY, chipW, chipH;
float inPlusX, inPlusY, inMinusX, inMinusY, outPinX, outPinY;
float outX, outY, outW, outH;
float u;

FlowPath mainFlow, gndFlow, potFlow;

void settings() {
  int w = max(1000, displayWidth - 80);
  int h = max(650, displayHeight - 150);
  size(w, h, P2D);
  pixelDensity(displayDensity());
  smooth(8);
}

void setup() {
  surface.setTitle("Flame Module  �  Circuit Simulation");
  surface.setResizable(true);
  surface.setLocation(50, 50);
  frameRate(60);
  hint(ENABLE_STROKE_PURE);
  strokeCap(ROUND);
  strokeJoin(ROUND);

  COL_BG = color(248, 246, 241);
  COL_CARD = color(255);
  COL_INK = color(22, 28, 40);
  COL_MUTED = color(70, 82, 96);
  COL_YELLOW = color(242, 186, 22);
  COL_RED = color(220, 38, 38);
  COL_RAIL = color(40, 48, 60);

  makeFonts();
  layout();
  refreshPorts();
  lastW = width;
  lastH = height;
}

void makeFonts() {
  float s = min(width, height);
  fontTitle = createFont("Segoe UI Bold", s * 0.042, true);
  fontUi = createFont("Segoe UI", s * 0.026, true);
  fontSmall = createFont("Segoe UI", s * 0.022, true);
  fontHuge = createFont("Segoe UI Bold", s * 0.088, true);
}

void layout() {
  u = min(width, height) / 900.0;

  btnX = width * 0.028;
  btnY = height * 0.145;
  btnW = width * 0.13;
  btnH = height * 0.07;
  lightX = width * 0.088;
  lightY = height * 0.52;

  portX = width * 0.02;
  portY = height * 0.018;
  portW = width * 0.16;
  portH = height * 0.042;
  connX = portX + portW + width * 0.01;
  connW = width * 0.10;

  vccY = height * 0.20;
  gndY = height * 0.88;
  pdX = width * 0.28;
  aoY = height * 0.50;
  rY = height * 0.72;
  potX = width * 0.43;
  potY = height * 0.64;

  chipX = width * 0.52;
  chipY = height * 0.34;
  chipW = width * 0.17;
  chipH = height * 0.32;

  inPlusX = chipX;
  inPlusY = chipY + chipH * 0.32;
  inMinusX = chipX;
  inMinusY = chipY + chipH * 0.68;
  outPinX = chipX + chipW;
  outPinY = chipY + chipH * 0.50;

  outX = width * 0.72;
  outY = height * 0.175;
  outW = width * 0.255;
  outH = height * 0.70;

  mainFlow = new FlowPath();
  mainFlow.add(pdX, vccY);
  mainFlow.add(pdX, height * 0.29);
  mainFlow.add(pdX, aoY);
  mainFlow.add(chipX - width * 0.02, aoY);
  mainFlow.add(chipX - width * 0.02, inPlusY);
  mainFlow.add(inPlusX, inPlusY);
  mainFlow.add(chipX + chipW * 0.5, inPlusY);
  mainFlow.add(chipX + chipW * 0.5, outPinY);
  mainFlow.add(outPinX, outPinY);
  mainFlow.add(outX, outPinY);

  gndFlow = new FlowPath();
  gndFlow.add(pdX, aoY);
  gndFlow.add(pdX, rY);
  gndFlow.add(pdX, gndY);

  potFlow = new FlowPath();
  potFlow.add(potX, potY);
  potFlow.add(potX, inMinusY);
  potFlow.add(inMinusX, inMinusY);
}

void draw() {
  if (width != lastW || height != lastH) {
    makeFonts();
    layout();
    lastW = width;
    lastH = height;
  }

  pumpSerial();
  background(COL_BG);
  if (!connected) updateCircuit();

  flowPhase += 0.0032;
  if (flowPhase > 1) flowPhase -= 1;
  flameFlicker = 0.6 + 0.4 * sin(millis() * 0.01);

  int flowCol = lighterOn ? COL_RED : COL_YELLOW;

  drawHeader();
  drawStageCards();
  drawLighter();
  drawCircuit(flowCol);
  drawOutput();
  drawFooter();
}

void updateCircuit() {
  int target = lighterOn
    ? 160 + int(sin(millis() * 0.02) * 12)
    : 900 + int(noise(millis() * 0.0008) * 12);
  analogValue = int(lerp(analogValue, constrain(target, 0, 1023), 0.12));
  digitalOut = (lighterOn && analogValue < threshold) ? 1 : 0;
}

void drawHeader() {
  noStroke();
  fill(COL_CARD);
  rect(0, 0, width, height * 0.11);

  fill(connected ? color(22, 163, 74) : color(55, 65, 81));
  rect(portX, portY, portW, portH, 8);
  fill(255);
  textFont(fontSmall);
  textAlign(CENTER, CENTER);
  String portName = (ports.length == 0) ? "No COM port" : ports[portIndex];
  text(portName, portX + portW * 0.5, portY + portH * 0.5);

  fill(connected ? COL_RED : color(22, 163, 74));
  rect(connX, portY, connW, portH, 8);
  fill(255);
  text(connected ? "Disconnect" : "Connect", connX + connW * 0.5, portY + portH * 0.5);

  fill(COL_INK);
  textFont(fontTitle);
  textAlign(CENTER, CENTER);
  text("Flame Detection Module", width * 0.5, height * 0.045);

  fill(COL_MUTED);
  textFont(fontSmall);
  text(connected ? "LIVE Arduino 9600     yellow = HIGH     red = voltage DROP" : "DEMO / LIVE     yellow = HIGH voltage     red = voltage DROP", width * 0.5, height * 0.082);
}

void drawStageCards() {
  float y = height * 0.125;
  float h = height * 0.042;
  stageLabel(width * 0.22, y, width * 0.16, h, "1   Sensor");
  stageLabel(width * 0.40, y, width * 0.12, h, "2   Threshold");
  stageLabel(width * 0.52, y, width * 0.17, h, "3   LM393 IC");
  stageLabel(width * 0.72, y, width * 0.255, h, "4   Output");
}

void stageLabel(float x, float y, float w, float h, String t) {
  noStroke();
  fill(236, 232, 224);
  rect(x, y, w, h, 8);
  fill(COL_INK);
  textFont(fontUi);
  textAlign(CENTER, CENTER);
  text(t, x + w * 0.5, y + h * 0.5);
}

void drawLighter() {
  noStroke();
  fill(lighterOn ? COL_RED : color(45, 52, 64));
  rect(btnX, btnY, btnW, btnH, 12 * u);
  fill(255);
  textFont(fontUi);
  textAlign(CENTER, CENTER);
  text(lighterOn ? "FLAME  ON" : "FLAME  OFF", btnX + btnW * 0.5, btnY + btnH * 0.5);

  float bw = width * 0.038;
  float bh = height * 0.17;
  pushMatrix();
  translate(lightX, lightY);
  fill(232, 92, 40);
  stroke(120, 42, 18);
  strokeWeight(2.5 * u);
  rect(-bw, -bh * 0.08, bw * 2, bh, 10 * u);
  fill(36, 36, 40);
  noStroke();
  rect(-bw * 0.75, -bh * 0.22, bw * 1.5, bh * 0.16, 5 * u);
  fill(190);
  rect(-bw * 0.28, -bh * 0.34, bw * 0.56, bh * 0.13, 3 * u);
  if (lighterOn) {
    float f = bh * 0.28 + 8 * flameFlicker;
    fill(255, 140, 20, 230);
    ellipse(0, -bh * 0.52, bw * 1.05, f + 16);
    fill(255, 220, 80, 240);
    ellipse(0, -bh * 0.48, bw * 0.5, f);
    fill(255, 255, 240, 210);
    ellipse(0, -bh * 0.43, bw * 0.22, f * 0.4);
  }
  popMatrix();

  fill(COL_INK);
  textFont(fontSmall);
  textAlign(CENTER, TOP);
  text(lighterOn ? "IR  760 - 1100 nm" : "No flame", lightX, lightY + bh * 0.98);
  fill(COL_MUTED);
  text(connected ? "Follows Arduino DO/AO" : "Click ON / OFF (demo)", lightX, lightY + bh * 1.14);

  if (lighterOn) {
    stroke(COL_RED, 180);
    strokeWeight(3 * u);
    float x0 = lightX + bw * 0.9;
    float y0 = lightY - bh * 0.5;
    float x1 = pdX - 40 * u;
    float y1 = height * 0.32;
    for (int i = 0; i < 3; i++) {
      float t0 = (i / 3.0 + flowPhase) % 1.0;
      float t1 = min(1, t0 + 0.22);
      line(
        lerp(x0, x1, t0), lerp(y0, y1, t0) + 5 * sin(t0 * 10),
        lerp(x0, x1, t1), lerp(y0, y1, t1) + 5 * sin(t1 * 10)
      );
    }
    fill(COL_RED);
    noStroke();
    textFont(fontUi);
    text("IR", (x0 + x1) * 0.5, (y0 + y1) * 0.5 - 18 * u);
  }
}

void drawCircuit(int flowCol) {
  float railL = width * 0.20;
  float railR = width * 0.70;

  stroke(COL_RAIL);
  strokeWeight(6 * u);
  line(railL, vccY, railR, vccY);
  line(railL, gndY, railR, gndY);

  fill(COL_RED);
  noStroke();
  ellipse(railL, vccY, 14 * u, 14 * u);
  fill(COL_INK);
  ellipse(railL, gndY, 14 * u, 14 * u);

  textFont(fontUi);
  textAlign(RIGHT, CENTER);
  fill(COL_RED);
  text("5V", railL - 12 * u, vccY);
  fill(COL_INK);
  text("GND", railL - 12 * u, gndY);

  mainFlow.drawCable(flowCol, 5 * u);
  gndFlow.drawCable(flowCol, 4.5 * u);
  potFlow.drawCable(flowCol, 4.5 * u);

  mainFlow.drawFlow(flowPhase, flowCol, 4, 16 * u);
  gndFlow.drawFlow(flowPhase + 0.35, flowCol, 3, 14 * u);
  potFlow.drawFlow(flowPhase + 0.55, flowCol, 3, 14 * u);

  float pdW = 70 * u;
  float pdH = 84 * u;
  fill(20, 24, 34);
  stroke(flowCol);
  strokeWeight(3.5 * u);
  ellipse(pdX, height * 0.325, pdW, pdH);
  noStroke();
  fill(40, 46, 58);
  ellipse(pdX, height * 0.31, pdW * 0.4, pdH * 0.28);

  fill(COL_INK);
  textFont(fontUi);
  textAlign(LEFT, CENTER);
  text("YG1006", pdX + pdW * 0.62, height * 0.308);
  textFont(fontSmall);
  fill(COL_MUTED);
  text("IR photodiode", pdX + pdW * 0.62, height * 0.338);
  fill(lighterOn ? COL_RED : color(20, 130, 70));
  text(lighterOn ? "R drops  ->  voltage LOW" : "R high  ->  voltage HIGH", pdX + pdW * 0.62, height * 0.368);

  fill(flowCol);
  stroke(COL_INK);
  strokeWeight(2.5 * u);
  ellipse(pdX, aoY, 22 * u, 22 * u);
  fill(COL_INK);
  noStroke();
  textFont(fontUi);
  textAlign(LEFT, CENTER);
  text("AO  analog", pdX + 20 * u, aoY - 16 * u);
  textFont(fontSmall);
  fill(COL_MUTED);
  text(nf(analogValue / 1023.0 * 5.0, 1, 2) + " V", pdX + 20 * u, aoY + 10 * u);

  fill(255, 248, 220);
  stroke(COL_INK);
  strokeWeight(2.2 * u);
  rect(pdX - 22 * u, rY - 38 * u, 44 * u, 76 * u, 6 * u);
  fill(COL_INK);
  noStroke();
  textFont(fontSmall);
  textAlign(CENTER, CENTER);
  pushMatrix();
  translate(pdX, rY);
  rotate(-HALF_PI);
  text("10 kOhm", 0, 0);
  popMatrix();
  textAlign(LEFT, CENTER);
  text("divider", pdX + 30 * u, rY);

  gndMark(pdX, gndY);

  float ps = 78 * u;
  fill(37, 99, 235);
  stroke(147, 197, 253);
  strokeWeight(2.8 * u);
  rect(potX - ps * 0.5, potY - ps * 0.5, ps, ps, 12 * u);
  fill(219, 234, 254);
  noStroke();
  ellipse(potX, potY, ps * 0.62, ps * 0.62);
  pushMatrix();
  translate(potX, potY);
  rotate(map(threshold, 0, 1023, -2.3, 2.3));
  fill(30, 41, 59);
  rect(-3.5 * u, -ps * 0.28, 7 * u, ps * 0.28, 2 * u);
  popMatrix();
  fill(COL_INK);
  textFont(fontUi);
  textAlign(CENTER, TOP);
  text("10 kOhm  POT", potX, potY + ps * 0.56);
  textFont(fontSmall);
  fill(COL_MUTED);
  text("threshold  " + threshold, potX, potY + ps * 0.80);

  fill(22, 26, 36);
  stroke(flowCol);
  strokeWeight(3.5 * u);
  rect(chipX, chipY, chipW, chipH, 12 * u);
  fill(255);
  noStroke();
  ellipse(chipX + 16 * u, chipY + 16 * u, 10 * u, 10 * u);
  textFont(fontTitle);
  textAlign(CENTER, CENTER);
  text("LM393", chipX + chipW * 0.5, chipY + chipH * 0.44);
  textFont(fontSmall);
  fill(175, 185, 200);
  text("comparator", chipX + chipW * 0.5, chipY + chipH * 0.58);
  fill(flowCol);
  textFont(fontUi);
  text(lighterOn ? "LOW vs pot" : "HIGH vs pot", chipX + chipW * 0.5, chipY + chipH * 0.72);

  pinDot(inPlusX, inPlusY);
  pinDot(inMinusX, inMinusY);
  pinDot(outPinX, outPinY);

  fill(230, 235, 245);
  textFont(fontSmall);
  textAlign(LEFT, CENTER);
  text("IN+  AO", chipX + 16 * u, inPlusY);
  text("IN-  POT", chipX + 16 * u, inMinusY);
  textAlign(RIGHT, CENTER);
  text("OUT", chipX + chipW - 16 * u, outPinY);
}

void pinDot(float x, float y) {
  fill(12, 16, 24);
  stroke(240);
  strokeWeight(2 * u);
  ellipse(x, y, 12 * u, 12 * u);
}

void gndMark(float x, float y) {
  stroke(COL_INK);
  strokeWeight(3.5 * u);
  line(x - 18 * u, y, x + 18 * u, y);
  strokeWeight(2.8 * u);
  line(x - 12 * u, y + 8 * u, x + 12 * u, y + 8 * u);
  line(x - 6 * u, y + 16 * u, x + 6 * u, y + 16 * u);
}

void drawOutput() {
  fill(COL_CARD);
  stroke(210, 204, 194);
  strokeWeight(2 * u);
  rect(outX, outY, outW, outH, 14 * u);

  fill(lighterOn ? COL_RED : COL_YELLOW);
  noStroke();
  rect(outX + outW * 0.06, outY + outH * 0.035, outW * 0.88, outH * 0.085, 10 * u);
  fill(20);
  textFont(fontUi);
  textAlign(CENTER, CENTER);
  text(lighterOn ? "VOLTAGE DROP  (LOW)" : "NORMAL VOLTAGE  (HIGH)", outX + outW * 0.5, outY + outH * 0.077);

  textAlign(LEFT, TOP);
  fill(COL_MUTED);
  textFont(fontSmall);
  text("ANALOG", outX + outW * 0.08, outY + outH * 0.15);
  fill(COL_INK);
  textFont(fontHuge);
  text(str(analogValue), outX + outW * 0.08, outY + outH * 0.19);
  textFont(fontUi);
  fill(COL_MUTED);
  text("0 - 1023", outX + outW * 0.08, outY + outH * 0.32);
  text(nf(analogValue / 1023.0 * 5.0, 1, 2) + " V  on AO", outX + outW * 0.40, outY + outH * 0.32);

  float barX = outX + outW * 0.08;
  float barY = outY + outH * 0.38;
  float barW = outW * 0.84;
  float barH = 18 * u;
  fill(241, 245, 249);
  noStroke();
  rect(barX, barY, barW, barH, 6 * u);
  fill(flowColor());
  rect(barX, barY, map(analogValue, 0, 1023, 0, barW), barH, 6 * u);
  stroke(37, 99, 235);
  strokeWeight(3 * u);
  float tx = barX + map(threshold, 0, 1023, 0, barW);
  line(tx, barY - 5 * u, tx, barY + barH + 5 * u);

  noStroke();
  fill(COL_MUTED);
  textFont(fontSmall);
  textAlign(LEFT, TOP);
  text("DIGITAL", outX + outW * 0.08, outY + outH * 0.45);

  fill(digitalOut == 1 ? COL_RED : color(55, 64, 78));
  textFont(fontHuge);
  text(str(digitalOut), outX + outW * 0.08, outY + outH * 0.49);

  textFont(fontUi);
  fill(COL_MUTED);
  text(digitalOut == 1 ? "1   flame detected" : "0   no flame", outX + outW * 0.30, outY + outH * 0.54);

  float bw = outW * 0.38;
  float bh = outH * 0.11;
  float b1 = outX + outW * 0.08;
  float b0 = outX + outW * 0.54;
  float by = outY + outH * 0.66;
  fill(digitalOut == 1 ? COL_RED : color(200, 204, 210));
  rect(b1, by, bw, bh, 10 * u);
  fill(digitalOut == 0 ? color(45, 52, 64) : color(200, 204, 210));
  rect(b0, by, bw, bh, 10 * u);
  fill(255);
  textFont(fontTitle);
  textAlign(CENTER, CENTER);
  text("1", b1 + bw * 0.5, by + bh * 0.5);
  text("0", b0 + bw * 0.5, by + bh * 0.5);

  fill(COL_MUTED);
  textFont(fontSmall);
  textAlign(CENTER, TOP);
  text(connected ? "LIVE  A0 + D2 from Arduino" : "DEMO  (not connected)", outX + outW * 0.5, outY + outH * 0.82);
  text(serialStatus, outX + outW * 0.5, outY + outH * 0.87);
}

int flowColor() {
  return lighterOn ? COL_RED : COL_YELLOW;
}

void drawFooter() {
  fill(COL_MUTED);
  textFont(fontSmall);
  textAlign(LEFT, BOTTOM);
  text("YELLOW  HIGH  output 0      RED  LOW  output 1      Click COM then Connect", width * 0.02, height - height * 0.018);
  textAlign(RIGHT, BOTTOM);
  text("SPACE demo on/off     wheel = threshold     R reset", width * 0.98, height - height * 0.018);
}

void mousePressed() {
  if (mouseX > portX && mouseX < portX + portW && mouseY > portY && mouseY < portY + portH) {
    refreshPorts();
    if (ports.length > 0) portIndex = (portIndex + 1) % ports.length;
    return;
  }
  if (mouseX > connX && mouseX < connX + connW && mouseY > portY && mouseY < portY + portH) {
    toggleConnect();
    return;
  }
  if (connected) return;
  if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
    lighterOn = !lighterOn;
  }
  if (dist(mouseX, mouseY, lightX, lightY) < height * 0.12) {
    lighterOn = !lighterOn;
  }
  if (dist(mouseX, mouseY, potX, potY) < 50 * u) {
    draggingPot = true;
  }
}

void mouseDragged() {
  if (draggingPot && !connected) {
    threshold = constrain(threshold + (mouseX - pmouseX) * 2, 0, 1023);
  }
}

void mouseReleased() {
  draggingPot = false;
}

void mouseWheel(MouseEvent e) {
  if (!connected) {
    threshold = constrain(threshold - int(e.getCount()) * 8, 0, 1023);
  }
}

void keyPressed() {
  if (key == ' ' && !connected) lighterOn = !lighterOn;
  if (key == 'r' || key == 'R') {
    if (!connected) lighterOn = false;
    threshold = 500;
  }
  if (key == 'c' || key == 'C') toggleConnect();
}

void refreshPorts() {
  ports = Serial.list();
  if (ports == null) ports = new String[0];
  if (portIndex >= ports.length) portIndex = max(0, ports.length - 1);
  if (ports.length == 0) serialStatus = "No COM port. Plug in Arduino.";
}

void toggleConnect() {
  if (connected) {
    disconnect();
    return;
  }
  refreshPorts();
  if (ports.length == 0) {
    serialStatus = "No COM port found.";
    return;
  }
  try {
    serial = new Serial(this, ports[portIndex], 9600);
    serial.clear();
    serial.bufferUntil('\n');
    connected = true;
    serialStatus = "LIVE  " + ports[portIndex] + "  9600 baud";
  }
  catch (Exception e) {
    connected = false;
    serial = null;
    serialStatus = "Port busy. Close Arduino Serial Monitor.";
  }
}

void disconnect() {
  if (serial != null) {
    try { serial.stop(); } catch (Exception e) {}
  }
  serial = null;
  connected = false;
  serialStatus = "Disconnected. Demo mode.";
}

void pumpSerial() {
  if (!connected || serial == null) return;
  while (serial.available() > 0) {
    String line = serial.readStringUntil('\n');
    if (line == null) break;
    applySerialLine(line);
  }
}

void applySerialLine(String line) {
  line = trim(line);
  if (line.length() < 3) return;

  int aIdx = line.indexOf("A:");
  int dIdx = line.indexOf("D:");
  int fIdx = line.indexOf("F:");
  if (aIdx >= 0 && dIdx > aIdx) {
    analogValue = constrain(int(trim(between(line, aIdx + 2, commaOrEnd(line, aIdx + 2)))), 0, 1023);
    int rawDo = int(trim(between(line, dIdx + 2, commaOrEnd(line, dIdx + 2))));
    if (fIdx > 0) {
      digitalOut = constrain(int(trim(between(line, fIdx + 2, line.length()))), 0, 1);
    } else {
      digitalOut = (rawDo == 0) ? 1 : 0;
    }
    lighterOn = digitalOut == 1;
    return;
  }

  int an = line.indexOf("Analog:");
  int dn = line.indexOf("Digital:");
  if (an >= 0 && dn > an) {
    analogValue = constrain(int(trim(between(line, an + 7, dn))), 0, 1023);
    int rawDo = int(trim(line.substring(dn + 8)));
    digitalOut = (rawDo == 0) ? 1 : 0;
    lighterOn = digitalOut == 1;
  }
}

String between(String s, int start, int end) {
  start = constrain(start, 0, s.length());
  end = constrain(end, start, s.length());
  return s.substring(start, end);
}

int commaOrEnd(String s, int from) {
  int c = s.indexOf(',', from);
  return (c < 0) ? s.length() : c;
}

class FlowPath {
  ArrayList<PVector> pts = new ArrayList<PVector>();

  void add(float x, float y) {
    pts.add(new PVector(x, y));
  }

  float lengthTotal() {
    float s = 0;
    for (int i = 1; i < pts.size(); i++) {
      s += PVector.dist(pts.get(i - 1), pts.get(i));
    }
    return max(1, s);
  }

  PVector at(float t) {
    t = constrain(t, 0, 1);
    float target = t * lengthTotal();
    float acc = 0;
    for (int i = 1; i < pts.size(); i++) {
      PVector a = pts.get(i - 1);
      PVector b = pts.get(i);
      float seg = PVector.dist(a, b);
      if (acc + seg >= target) {
        float uSeg = (target - acc) / max(0.001, seg);
        return PVector.lerp(a, b, uSeg);
      }
      acc += seg;
    }
    return pts.get(pts.size() - 1).copy();
  }

  void drawCable(int col, float wt) {
    if (pts.size() < 2) return;
    stroke(red(col), green(col), blue(col), 55);
    strokeWeight(wt + 8 * u);
    noFill();
    beginShape();
    for (PVector p : pts) vertex(p.x, p.y);
    endShape();
    stroke(col);
    strokeWeight(wt);
    beginShape();
    for (PVector p : pts) vertex(p.x, p.y);
    endShape();
  }

  void drawFlow(float phase, int col, int beads, float sz) {
    if (pts.size() < 2) return;
    for (int i = 0; i < beads; i++) {
      float t = (phase + i / float(beads)) % 1.0;
      PVector p = at(t);
      noStroke();
      fill(red(col), green(col), blue(col), 50);
      ellipse(p.x, p.y, sz + 10 * u, sz + 10 * u);
      fill(col);
      ellipse(p.x, p.y, sz, sz);
      fill(255, 252, 240);
      ellipse(p.x - 2 * u, p.y - 2 * u, sz * 0.28, sz * 0.28);
    }
  }
}

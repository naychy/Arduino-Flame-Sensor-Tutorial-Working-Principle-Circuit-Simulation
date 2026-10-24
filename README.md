# Arduino-Flame-Sensor-Tutorial-Working-Principle-Circuit-Simulation
Arduino and Processing code for building a smart fire detection system using a Flame Sensor (LM393), featuring real-time circuit simulation and data visualization.
Arduino Flame Sensor & Processing Visualization

This repository contains the Arduino and Processing source code for building a smart fire detection system. It demonstrates how to read analog and digital signals from an infrared Flame Sensor (LM393) and visualize the data in real-time using a custom Processing interface.
Features

    Dual Signal Reading: Processes both analog and digital outputs from the LM393 flame sensor module.

    Real-Time Visualization: Uses Processing to create a live, interactive visualization of the sensor's state and circuit behavior.

    Alarm Trigger: Activates a buzzer automatically when the fire threshold is crossed.

Hardware Requirements

    Arduino Uno (or compatible microcontroller)

    Flame Sensor Module (LM393)

    5V Buzzer

    Jumper Wires

Circuit Wiring

    Flame Sensor: VCC to Arduino 5V, GND to GND, A0 to Analog A0, D0 to Digital Pin 8.

    Buzzer: Positive + to Digital Pin 9, Negative - to GND.

Installation and Usage

    Clone this repository to your local machine.

    Open the provided Arduino sketch in the Arduino IDE and upload it to your board. Note the active COM port.

    Open the Processing sketch in the Processing IDE.

    Update the Serial.list()[x] index or directly input your COM port in the Processing code to match your Arduino's connection.

    Run the Processing sketch to view the real-time simulation.

Video Tutorial

For a complete step-by-step guide on the working principles, circuit assembly, and code explanation, watch the full tutorial on the ECTUTO YouTube channel:
https://www.youtube.com/watch?v=oxl4aWP0kk0

# Main Python script for mission LASPA v 1.0
# Created by: Karolina Joachimczyk
# Pinout mapping: 
# PUMP EN - 17
# RPI TX - 14 (OPENLOG RX)
# RPI RX - 15 (OPENLOG TX)

# Code section: when powered up, a service start running this script in infinite loop.
# Should power be cut off, latest logs will be considered while reopening.

import numpy as np
import sys
import serial
import datetime
import RPi.GPIO as GPIO
import time
import os
import picamera
import psutil
from __future__ import print_function

GPIO.setmode(GPIO.BCM)
PUMP_PIN = 17

serial_port = '/dev/serial0'
baud_rate = 9600
camera = picamera.PiCamera()
GPIO.setup(PUMP_PIN, GPIO.OUT)

ser = serial.Serial(serial_port, baud_rate, timeout=1)

# PUMP control
def turn_pump_off():
    GPIO.output(PUMP_PIN, GPIO.LOW)
    print("Pump is OFF (LOW)")
    
def turn_pump_on():
    GPIO.output(PUMP_PIN, GPIO.HIGH)
    print("Pump is ON (HIGH)")

# To read data from sensor
def read_co2():
    try:
        ser.flush()
        co2_data = ser.readline().decode().strip()
        return co2_data
    except Exception as e:
        return f"Error reading CO2 sensor: {e}"

# To read data from sensor
def read_bme680():
    # Dummy values, replace with actual sensor reading logic
    temperature = 22.5  # Celsius
    pressure = 1013.25  # hPa
    humidity = 50.2  # %
    gas_resistance = 100  # Example value
    return temperature, pressure, humidity, gas_resistance

# LOGS SECTION - CPU temp, CO2, BME680 (t, h, p, g), pump stat, camera activity 

def get_cpu_temperature():
    temp = psutil.sensors_temperatures().get('cpu-thermal', None)
    return temp[0].current if temp else None

def log_data(log_message):
    with open("/path/to/log_file.txt", "a") as log_file:
        log_file.write(log_message + '\n')
        
def get_cpu_temperature_status():
    temp = psutil.sensors_temperatures().get('cpu-thermal', None)
    cpu_temp = temp[0].current if temp else None
    if cpu_temp is not None:
        if cpu_temp < 70:  # Threshold for CPU temp
            return 1  # CPU is fine
        else:
            return 0  # CPU temp is too high
    return 0  # Error case or missing data

def get_co2_status():
    try:
        ser.flush()
        co2_reading = float(ser.readline().decode().strip())
        if co2_reading < 1000:  # Safe CO2 level
            return 1  # CO2 level is fine
        else:
            return 0  # CO2 level is too high
    except Exception:
        return 0  # Error or no data
    
def get_bme680_status():
    # Dummy values
    temp = 25.0  # Replace with actual temperature reading
    humidity = 45.0  # Replace with actual humidity reading
    pressure = 1013.0  # Replace with actual pressure reading
    gas_resistance = 200  # Replace with actual gas resistance

    # Define binary conditions
    temp_status = 1 if 15 <= temp <= 30 else 0  # Acceptable temperature range
    humidity_status = 1 if 30 <= humidity <= 60 else 0  # Comfortable humidity
    pressure_status = 1 if 950 <= pressure <= 1050 else 0  # Normal atmospheric pressure
    gas_status = 1 if gas_resistance > 100 else 0  # Good air quality based on gas resistance
    
def get_pump_status():
    return 1 if GPIO.input(PUMP_PIN) == GPIO.HIGH else 0

def get_camera_status():
    try:
        image_path = f"/path/to/images/image_{datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.jpg"
        camera.capture(image_path)
        return 1  # Successfully captured image
    except Exception:
        return 0  # Failed to capture image

# Main loop
try:
    
    start_timestamp = None  # Variable to store the time when pump last started

    while True:
        # Get the current date and time
        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Retrieve all statuses
        cpu_temp_status = get_cpu_temperature_status()
        co2_status = get_co2_status()
        temp_status, humidity_status, pressure_status, gas_status = get_bme680_status()
        pump_status = get_pump_status()
        camera_status = get_camera_status()

        # Format log message (binary status for each)
        log_message = (f"{current_time}, "
                       f"CPU Temp: {cpu_temp_status}, "
                       f"CO2: {co2_status}, "
                       f"Temp: {temp_status}, Humidity: {humidity_status}, "
                       f"Pressure: {pressure_status}, Gas: {gas_status}, "
                       f"Pump: {pump_status}, Camera: {camera_status}")
        
        # Log data to file
        log_data(log_message)

        # Print to console (optional)
        print(log_message)

        # Wait for 5 seconds before next iteration
        time.sleep(5)

except KeyboardInterrupt:
    # Clean up GPIO on exit
    GPIO.cleanup()
    ser.close()
    camera.close()
    print("Stopped logging.")
    
except (serial.SerialException, OSError) as e:
    print(f"Error: Serial communication failed: {e}. Exiting program...")
    # Clean up GPIO and close serial connection
    GPIO.cleanup()
    if ser:
        ser.close()
    camera.close()
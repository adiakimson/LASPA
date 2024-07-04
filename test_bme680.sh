#!/bin/bash

echo Script for bme680 testing
echo Starting i2c test...

sudo i2cdetect -y 1 > i2cout_test.txt

echo Check i2c results...

cat i2cout_test.txt

cd DFRobot_SCD4X/python/raspberrypi/examples
python3 zapis.py

trap ctrl_c INT

function ctrl_c() {
    echo -e "\nCtrl+C pressed. Displaying sensor_data.txt content:\n"
    cat sensor_data.txt
    exit
}

echo Script finished.





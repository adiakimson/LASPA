#!/bin/bash

# Variables
SERVICE_NAME="mission.service"
SCRIPT_PATH="/home/pi/mission.py" #python script start
PYTHON_PATH="/usr/bin/python3"
WORKING_DIR="/home/pi"
USER="pi" #modify
GROUP="pi" #modify

# Create the systemd service file
echo "Creating the systemd service file..."

sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME <<EOF
[Unit]
Description=Mission Python Script
After=network.target

[Service]
ExecStart=$PYTHON_PATH $SCRIPT_PATH
WorkingDirectory=$WORKING_DIR
StandardOutput=inherit
StandardError=inherit
Restart=always
User=$USER
Group=$GROUP

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd to recognize the new service file
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable the service to start on boot
echo "Enabling the service..."
sudo systemctl enable $SERVICE_NAME

# Start the service immediately
echo "Starting the service..."
sudo systemctl start $SERVICE_NAME

# Check the status of the service
echo "Checking the status of the service..."
sudo systemctl status $SERVICE_NAME

echo "Service setup complete."

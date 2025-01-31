#!/bin/bash

# Log file for network checks
LOGFILE="/var/log/ice_cubes_network.log"
AOS=false  # Acquisition of Signal (initially assume no signal)

# Function to get local IP address (eth0 only)
get_local_ip() {
    local_ip=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
    
    if [[ -z "$local_ip" ]]; then
        local_ip="Unable to retrieve local IP on eth0"
    fi

    echo "Local IP Address (eth0): $local_ip"
    echo "$(date): Local IP Address (eth0): $local_ip" >> $LOGFILE
}

# Function to get public IP address
get_public_ip() {
    public_ip=$(curl -s https://ifconfig.me)
    
    if [[ -z "$public_ip" ]]; then
        public_ip="Unable to retrieve public IP"
    fi
    
    echo "Public IP Address: $public_ip"
    echo "$(date): Public IP Address: $public_ip" >> $LOGFILE
}

# Function to ping a sample network (Google DNS 8.8.8.8)
ping_network() {
    ping -c 4 8.8.8.8 &> /dev/null
    
    if [[ $? -eq 0 ]]; then
        echo "Network is reachable (ping success)"
        echo "$(date): Network is reachable (ping success)" >> $LOGFILE
        AOS=true  # Network reachable, so we have Acquisition of Signal
    else
        echo "Network is unreachable (ping failed)"
        echo "$(date): Network is unreachable (ping failed)" >> $LOGFILE
        AOS=false  # Network unreachable, signal is lost
    fi
}

# Function to handle failover and retry on LOS
check_network_with_failover() {
    while true; do
        if $AOS; then
            # During AOS, check the network every 60 seconds
            get_local_ip
            get_public_ip
            ping_network
            
            if ! $AOS; then
                echo "$(date): Lost Signal (LOS detected), retrying..." >> $LOGFILE
            fi
            
            sleep 60  # Wait for 60 seconds before next check
        else
            # During LOS, retry every 60 seconds to check if signal is restored
            echo "$(date): No Signal (LOS ongoing), attempting reconnection..." >> $LOGFILE
            ping_network  # Just check if the network is back

            if $AOS; then
                echo "$(date): Signal Restored (AOS detected)" >> $LOGFILE
            fi
            
            sleep 60  # Wait for 60 seconds before the next retry
        fi
    done
}

# Run the network check with failover logic
check_network_with_failover

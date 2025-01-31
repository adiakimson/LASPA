import subprocess

def main():
    # Get RTMP URL from user
    rtmp_url = input("Enter the RTMP URL (e.g., rtmp://server/live/stream): ")
    
    # Define the GStreamer pipeline command
    command = [
        "gst-launch-1.0",
        "raspivideosrc",
        "!",
        "video/x-h264,width=1280,height=720,framerate=30/1",
        "!",
        "h264parse",
        "!",
        "queue",
        "!",
        "flvmux",
        "!",
        f"rtmpsink location={rtmp_url}"
    ]
    
    # Run the command
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")
    except KeyboardInterrupt:
        print("Streaming stopped by user.")

if __name__ == '__main__':
    main()

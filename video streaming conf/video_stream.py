from picamera2 import Picamera2, Preview # Only works on RPi
import ffmpeg
import subprocess
import time

# Define RTMP server URL and key
rtmp_url = "rtmp://your-server-url/stream" # Change according to streaming
rtmp_key = "your-stream-key" # According to rtmp
rtmp_full_url = f"{rtmp_url}/{rtmp_key}"

# Stream video
def start_stream():
  # Initialize Picamera2
    picam2 = Picamera2()
    
    # Configure the camera settings
    picam2.configure(picam2.create_video_configuration(main={"format": "H264"}))
    picam2.start_preview(Preview.NULL)  # Use NULL to disable preview
    picam2.start_recording()

    # Start ffmpeg process for RTMP streaming
    ffmpeg_cmd = [
        'ffmpeg',
        '-re',  # Read input at native frame rate
        '-f', 'rawvideo',
        '-pix_fmt', 'yuv420p',
        '-s', '1920x1080',  # Change resolution as needed
        '-i', '-',  # Input from stdin
        '-c:v', 'libx264',
        '-preset', 'fast',
        '-b:v', '2000k',
        '-f', 'flv',
        rtmp_full_url
    ]
    
    process = subprocess.Popen(ffmpeg_cmd, stdin=subprocess.PIPE)
    
    try:
        # Stream video
        while True:
            frame = picam2.capture_array()
            process.stdin.write(frame.tobytes())
            time.sleep(0.1)  # Adjust frame rate if necessary
            
    except KeyboardInterrupt:
        print("Streaming stopped.")

    # Cleanup
    picam2.stop_recording()
    picam2.close()
    process.stdin.close()
    process.wait()
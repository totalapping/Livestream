#!/bin/bash

# Create app directory
mkdir -p /app

# Download video with retries
if [ ! -f "/app/video.mp4" ]; then
  echo "[$(date)] Downloading video..." >> /app/stream.log
  for i in {1..5}; do
    wget https://github.com/totalapping/Livestream/releases/download/v1.0/live.mp4 -O /app/video.mp4 && break
    echo "[$(date)] Download attempt $i failed" >> /app/stream.log
    sleep 10
  done
fi

# Verify video
if [ ! -f "/app/video.mp4" ]; then
  echo "[$(date)] ERROR: Video missing!" >> /app/stream.log
  exit 1
fi

# Streaming loop
while true; do
  echo "[$(date)] Starting vertical stream (720x1280)..." >> /app/stream.log
  
  ffmpeg -re -stream_loop -1 -i "/app/video.mp4" \
    -c:v libx264 -preset veryfast -b:v 3000k -maxrate 3500k -bufsize 6000k \
    -vf "scale=720:1280:force_original_aspect_ratio=decrease,pad=720:1280:(ow-iw)/2:(oh-ih)/2:black,format=yuv420p" \
    -g 60 -keyint_min 60 \
    -c:a aac -b:a 128k -ar 44100 \
    -f flv "rtmp://a.rtmp.youtube.com/live2/2ytm-kw83-gwbh-ch8p-fxhd" 2>> /app/ffmpeg.log
  
  echo "[$(date)] Stream restarting..." >> /app/stream.log
  sleep 5
done

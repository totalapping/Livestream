#!/bin/bash

# Memory limits (critical for Railway free tier)
ulimit -v 500000  # Limit to 500MB memory usage

# Create app directory
mkdir -p /app

# Download video (with retries)
if [ ! -f "/app/video.mp4" ]; then
  for i in {1..5}; do
    echo "[$(date)] Download attempt $i" >> /app/stream.log
    wget -q --show-progress https://github.com/totalapping/Livestream/releases/download/v1.0/live.mp4 -O /app/video.mp4 && break
    sleep 10
  done
fi

# Verify video
[ ! -f "/app/video.mp4" ] && echo "[$(date)] ERROR: Video missing!" >> /app/stream.log && exit 1

# Streaming loop with memory protection
while true; do
  echo "[$(date)] Starting stream (720x1280)..." >> /app/stream.log
  
  ffmpeg -loglevel warning -re -stream_loop -1 -i "/app/video.mp4" \
    -c:v libx264 -preset ultrafast -tune zerolatency \
    -b:v 2000k -maxrate 2500k -bufsize 4000k \
    -vf "scale=720:1280:force_original_aspect_ratio=decrease,pad=720:1280:(ow-iw)/2:(oh-ih)/2:black" \
    -g 60 -threads 1 \
    -c:a aac -b:a 96k -ar 44100 \
    -f flv "rtmp://a.rtmp.youtube.com/live2/2ytm-kw83-gwbh-ch8p-fxhd" 2>> /app/ffmpeg.log
  
  echo "[$(date)] Stream crashed! Restarting..." >> /app/stream.log
  sleep 5
done

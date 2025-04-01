#!/bin/bash

# Memory Management (Critical for Railway Free Tier)
ulimit -v 450000  # Limit to 450MB memory
echo 1 > /proc/sys/vm/overcommit_memory  # Prevent OOM kills

# Create app directory
mkdir -p /app

# Download video with retries (optimized)
if [ ! -f "/app/video.mp4" ]; then
  for i in {1..3}; do
    wget -q --show-progress https://github.com/totalapping/Livestream/releases/download/v1.0/live.mp4 -O /app/video.mp4 && break
    sleep 10
  done
fi

# Verify video
[ ! -f "/app/video.mp4" ] && echo "[$(date)] ERROR: Video missing!" >> /app/stream.log && exit 1

# Optimized FFmpeg Command for Vertical Stream
while true; do
  echo "[$(date)] Starting 9:16 stream (540x960 optimized)..." >> /app/stream.log
  
  ffmpeg -loglevel warning -re -stream_loop -1 -i "/app/video.mp4" \
    -c:v libx264 -preset ultrafast -tune zerolatency \
    -b:v 2000k -maxrate 2200k -bufsize 4000k \
    -vf "scale=540:960:force_original_aspect_ratio=decrease,pad=540:960:(ow-iw)/2:(oh-ih)/2:black" \
    -g 60 -threads 1 \
    -c:a aac -b:a 96k -ar 44100 \
    -f flv "rtmp://a.rtmp.youtube.com/live2/2ytm-kw83-gwbh-ch8p-fxhd" 2>> /app/ffmpeg.log
  
  sleep 5
done

#!/bin/bash
while true; do
  # पहले वीडियो डाउनलोड करें (एक बार)
  if [ ! -f "/app/video.mp4" ]; then
    wget https://github.com/totalapping/Livestream/releases/download/v1.0/live.mp4 -O /app/video.mp4
  fi
  
  # FFmpeg स्ट्रीमिंग (लूप सहित)
  ffmpeg -re -stream_loop -1 -i "/app/video.mp4" \
    -c:v libx264 -preset veryfast -b:v 2500k -maxrate 2500k -bufsize 5000k \
    -vf "scale=1280:720,fps=30" -g 60 -keyint_min 30 \
    -c:a aac -b:a 128k -ar 44100 \
    -f flv "rtmp://a.rtmp.youtube.com/live2/2ytm-kw83-gwbh-ch8p-fxhd"
  
  # अगर क्रैश हो तो 5 सेकंड रुककर फिरसे शुरू
  sleep 5
  echo "[$(date)] Stream restarted" >> /app/stream.log
done

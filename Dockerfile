FROM ubuntu:22.04
RUN apt-get update && apt-get install -y ffmpeg wget
COPY stream.sh /app/
RUN chmod +x /app/stream.sh
CMD ["/app/stream.sh"]

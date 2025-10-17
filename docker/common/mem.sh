INTERVAL_SECONDS="$1"
OUTPUT_FILE="$2"
TIME_FORMAT="$3"
if [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: INTERVAL_SECONDS must be provided."
  echo "Usage: $0 <INTERVAL_SECONDS> <OUTPUT_FILE> <TIME_FORMAT>"
  exit 1
fi

if [ -z "$OUTPUT_FILE" ]; then
  echo "Error: OUTPUT_FILE must be provided."
  echo "Usage: $0 <INTERVAL_SECONDS> <OUTPUT_FILE> <TIME_FORMAT>"
  exit 1
fi

if [ -z "$TIME_FORMAT" ]; then
  echo "Error: TIME_FORMAT must be provided."
  echo "Usage: $0 <INTERVAL_SECONDS> <OUTPUT_FILE> <TIME_FORMAT>"
  exit 1
fi

#if [ ! -f "$OUTPUT_FILE" ]; then
#  echo "Creating output file: $OUTPUT_FILE"
#  echo "timestamp,memory_usage_gib" > "$OUTPUT_FILE"
#fi

while true; do
  TIMESTAMP=$(date +$TIME_FORMAT)
  MEMORY_USAGE_BYTES=$(cat /sys/fs/cgroup/memory.current)
  MEMORY_USAGE_GIB=$(awk "BEGIN {printf \"%.2f\", $MEMORY_USAGE_BYTES / 1073741824}")
  echo "$TIMESTAMP,$MEMORY_USAGE_GIB" >> "$OUTPUT_FILE"
  sleep "$INTERVAL_SECONDS"
done

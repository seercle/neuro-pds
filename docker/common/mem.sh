INTERVAL_SECONDS="$1"

if [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: INTERVAL_SECONDS must be provided."
  echo "Usage: $0 <INTERVAL_SECONDS>"
  exit 1
fi

OUTPUT_FILE="/OUTPUTS/memory_usage.csv"
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "Creating output file: $OUTPUT_FILE"
  echo "timestamp,memory_usage_gib" > "$OUTPUT_FILE"
  sync
fi

while true; do
  TIMESTAMP=$(date +"%H:%M:%S")
  MEMORY_USAGE_BYTES=$(cat /sys/fs/cgroup/memory.current)
  MEMORY_USAGE_GIB=$(awk "BEGIN {printf \"%.2f\", $MEMORY_USAGE_BYTES / 1073741824}")
  echo "$TIMESTAMP,$MEMORY_USAGE_GIB" >> "$OUTPUT_FILE"
  sleep "$INTERVAL_SECONDS"
done

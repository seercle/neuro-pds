CONTAINER_NAME="$1"
INTERVAL_SECONDS="$2"

if [ -z "$CONTAINER_NAME" ] || [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: Both CONTAINER_NAME and INTERVAL_SECONDS must be provided."
  echo "Usage: $0 <CONTAINER_NAME> <INTERVAL_SECONDS>"
  exit 1
fi

OUTPUT_FILE="/OUTPUTS/memory_usage.csv"
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "Creating output file: $OUTPUT_FILE"
  echo "timestamp,memory_usage_gib" > "$OUTPUT_FILE"
fi

while true; do
  TIMESTAMP=$(date +"%H:%M:%S")
  MEMORY_USAGE_BYTES=$(cat /sys/fs/cgroup/memory.current)
  MEMORY_USAGE_GIB=$(awk "BEGIN {printf \"%.2f\", $MEMORY_USAGE_BYTES / 1073741824}")
  echo "$TIMESTAMP,$MEMORY_USAGE_GIB" >> "$OUTPUT_FILE"
  sleep "$INTERVAL_SECONDS"
done

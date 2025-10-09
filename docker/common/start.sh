BIN_BASH="/bin/bash"

if [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: Both CONTAINER_NAME and INTERVAL_SECONDS must be provided."
  echo "Usage: $0 <INTERVAL_SECONDS>"
  exit 1
fi

# Start the memory monitoring script in the background
$BIN_BASH /opt/mem.sh "$INTERVAL_SECONDS" &
MEM_SCRIPT_PID=$!

trap "kill $MEM_SCRIPT_PID" EXIT

# Start the SLANT application
$BIN_BASH /extra/run_deep_brain_seg.sh

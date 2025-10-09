CONTAINER_NAME="$1"
INTERVAL_SECONDS="$2"
BIN_BASH = "/bin/bash"

if [ -z "$CONTAINER_NAME" ] || [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: Both CONTAINER_NAME and INTERVAL_SECONDS must be provided."
  echo "Usage: $0 <CONTAINER_NAME> <INTERVAL_SECONDS>"
  exit 1
fi

# Start the memory monitoring script in the background
$BIN_BASH /opt/mem.sh "$CONTAINER_NAME" "$INTERVAL_SECONDS" &
MEM_SCRIPT_PID=$!

trap "kill $MEM_SCRIPT_PID" EXIT

# Start the SLANT application
$BIN_BASH /extra/run_deep_brain_seg.sh

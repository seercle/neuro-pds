BIN_BASH="/bin/bash"
DATE_FORMAT="%Y-%m-%d_%H:%M:%S"
if [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: INTERVAL_SECONDS must be provided."
  echo "Usage: $0 <INTERVAL_SECONDS>"
  exit 1
fi

LOG_FILE="/OUTPUTS/deep_brain_seg_logs.csv"
#echo "timestamp,log" > "$LOG_FILE"

# Iterate over files in /CUSTOM_INPUTS
find /CUSTOM_INPUTS -type f ! -path "*/.*" | sort | while read -r file; do
  if [ -f "$file" ]; then
    START_TIMESTAMP=$(date +$DATE_FORMAT)
    echo "$START_TIMESTAMP: Study of $(basename $file) started."

    # Clear the /INPUTS directory
    rm -rf /INPUTS/*

    # Copy the file to /INPUTS
    cp "$file" /INPUTS/

    # Start the memory monitoring script in the background
    $BIN_BASH /opt/mem.sh "$INTERVAL_SECONDS" &
    MEM_SCRIPT_PID=$!

    $BIN_BASH /extra/run_deep_brain_seg.sh 2>&1 | while IFS= read -r LOG; do
      TIMESTAMP=$(date +$DATE_FORMAT)
      echo "$TIMESTAMP,$LOG" >> "$LOG_FILE"
    done

    # Stop the memory monitoring script
    kill $MEM_SCRIPT_PID &>/dev/null

    # Create a directory in /CUSTOM_OUTPUTS named after the file
    filename=$(basename "$file")
    output_dir="/CUSTOM_OUTPUTS/$filename"
    mkdir -p "$output_dir"

    # Move the content of /OUTPUTS to the new directory
    mv /OUTPUTS/* "$output_dir/"

    END_TIMESTAMP=$(date +$DATE_FORMAT)
    echo "$END_TIMESTAMP: Study of $(basename $file) ended."

    start_seconds=$(date -d "$START_TIMESTAMP" +%s)
    end_seconds=$(date -d "$END_TIMESTAMP" +%s)
    elapsed_seconds=$((end_seconds - start_seconds))
    elapsed_minutes=$((elapsed_seconds / 60))
    echo "Elapsed time: $elapsed_minutes minutes"
    echo "----------------------------------------"

  fi
done

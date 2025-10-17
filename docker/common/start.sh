if [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: INTERVAL_SECONDS must be provided."
  echo "Usage: $0 <INTERVAL_SECONDS>"
  exit 1
fi

BIN_BASH="/bin/bash"
DATE_FORMAT="%Y-%m-%d_%H:%M:%S"
LOG_FILE="/OUTPUTS/deep_brain_seg_logs.csv"
MEMORY_USAGE_FILE="/OUTPUTS/memory_usage.csv"


# Iterate over files in /CUSTOM_INPUTS
find /CUSTOM_INPUTS -type f ! -path "*/.*" | sort | while read -r file; do
  if [ -f "$file" ]; then
    start_timestamp=$(date +%s)
    echo "$(date -d @$start_timestamp +$DATE_FORMAT): Study of $(basename $file) started."

    # Clear the /INPUTS directory
    rm -rf /INPUTS/*

    # Copy the file to /INPUTS
    cp "$file" /INPUTS/

    # Start the memory monitoring script in the background
    $BIN_BASH /opt/mem.sh "$INTERVAL_SECONDS" "$MEMORY_USAGE_FILE" &
    mem_script_pid=$!

    $BIN_BASH /extra/run_deep_brain_seg.sh 2>&1 | while IFS= read -r log; do
      timestamp=$(date +$DATE_FORMAT)
      echo "$timestamp,$log" >> "$LOG_FILE"
    done

    # Stop the memory monitoring script
    kill $mem_script_pid

    # Create a directory in /CUSTOM_OUTPUTS named after the file
    filename=$(basename "$file")
    output_dir="/CUSTOM_OUTPUTS/$filename"
    mkdir -p "$output_dir"

    # Move the content of /OUTPUTS to the new directory
    #mv /OUTPUTS/* "$output_dir/"
    mv $LOG_FILE "$output_dir/"
    mv $MEMORY_USAGE_FILE "$output_dir/"

    end_timestamp=$(date +%s)
    echo "$(date -d @$end_timestamp +$DATE_FORMAT): Study of $(basename $file) ended."

    elapsed_seconds=$((end_seconds - start_seconds))
    elapsed_minutes=$((elapsed_seconds / 60))
    echo "Elapsed time: $elapsed_minutes minutes"
    echo "----------------------------------------"

  fi
done

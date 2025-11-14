if [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: INTERVAL_SECONDS must be provided."
  exit 1
fi

DATE_FORMAT="%Y-%m-%d_%H:%M:%S"

LOGS_FILE="/OUTPUTS/logs.csv"
OUTPUT_FILE="/CUSTOM_OUTPUTS/output.csv"

# Ensure /CUSTOM_OUTPUTS and its contents are not owned by root
mkdir -p /CUSTOM_OUTPUTS
chmod -R u+rwX,go+rX,go-w /CUSTOM_OUTPUTS

echo "timestamp, log" > "$LOGS_FILE"
echo "filename,elapsed_minutes,file_size_mb" > "$OUTPUT_FILE"

# Iterate over files in /CUSTOM_INPUTS
find /CUSTOM_INPUTS -type f ! -path "*/.*" | sort | while read -r file; do
  if [ -f "$file" ]; then
    # Clear the /INPUTS directory
    rm -rf /INPUTS/*

    # Copy the file to /INPUTS
    cp "$file" /INPUTS/

    # Start the memory monitoring script in the background
    bash /opt/memory.sh "$INTERVAL_SECONDS" "/OUTPUTS/memory_trace.csv" "$DATE_FORMAT" &
    mem_script_pid=$!

    start_timestamp=$(date +%s)
    echo "$(date -d @$start_timestamp +$DATE_FORMAT): Study of $(basename $file) started."

    #bash /extra/run_deep_brain_seg.sh 2>&1 | while IFS= read -r log; do
    #  timestamp=$(date +$DATE_FORMAT)
    #  echo "$timestamp,$log" >> "$LOGS_FILE"
    #done
    sleep 10

    end_timestamp=$(date +%s)
    echo "$(date -d @$end_timestamp +$DATE_FORMAT): Study of $(basename $file) ended."

    # Stop the memory monitoring script
    kill $mem_script_pid

    # Create a directory in /CUSTOM_OUTPUTS named after the file
    file_name_ext=$(basename "$file" .nii.gz)
    file_name=$(basename "$file_name_ext" .nii.gz)
    mv /OUTPUTS "/CUSTOM_OUTPUTS/$file_name"
    chmod -R u+rwX,go+rX,go-w "/CUSTOM_OUTPUTS/$file_name"

    elapsed_seconds=$((end_timestamp - $start_timestamp))
    elapsed_minutes=$((elapsed_seconds / 60))
    echo "Elapsed time: $elapsed_minutes minutes"
    echo "----------------------------------------"

    # Get the size of the file
    file_size_bytes=$(stat -c%s "$file")
    file_size_mb=$(echo "scale=2; $file_size_bytes / 1024 / 1024" | bc)

    echo "$file_name_ext,$elapsed_minutes,$file_size_mb" >> "$OUTPUT_FILE"

  fi
done

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
echo "filename,elapsed_minutes" > "$OUTPUT_FILE"

find /CUSTOM_INPUTS -type d | sort | while read -r dir; do

  final_result=$(find "$dir/FinalResult" -type f -name "*.nii.gz" | head -n 1)
  if [ -z "$final_result" ]; then
    echo "No .nii.gz files found in $dir/FinalResult"
    continue
  fi

  file_name_ext=$(basename "$final_result")
  file_name=$(basename "$file_name_ext" .nii.gz)
  orig_image="$dir/$file_name/orig_target.nii.gz"
  if [ -f "$orig_image" ]; then
    echo "No valid orig_target.nii.gz files found in $dir/$file_name"
    continue
  fi

  rm -r /INPUTS/*
  cp "$orig_image" /INPUTS/T1.nii.gz
  cp "$final_result" /INPUTS/orig_target_seg.nii.gz

  bash /opt/mem.sh "$INTERVAL_SECONDS" "/OUTPUTS/memory_trace.csv" "$DATE_FORMAT" &
  mem_script_pid=$!

  start_timestamp=$(date +%s)
  echo "$(date -d @$start_timestamp +$DATE_FORMAT): Study of $($file_name).nii.gz started."

  bash /extra/MaCRUISE_v3_1_0 2>&1 | while IFS= read -r log; do
    timestamp=$(date +$DATE_FORMAT)
    echo "$timestamp,$log" >> "$LOGS_FILE"
  done

  end_timestamp=$(date +%s)
  echo "$(date -d @$end_timestamp +$DATE_FORMAT): Study of $($file_name).nii.gz ended."

  kill $mem_script_pid

  mv /OUTPUTS "/CUSTOM_OUTPUTS/$file_name"
  chmod -R u+rwX,go+rX,go-w "/CUSTOM_OUTPUTS/$file_name"

  elapsed_seconds=$((end_timestamp - start_timestamp))
  elapsed_minutes=$((elapsed_seconds / 60))
  echo "Elapsed time: $elapsed_minutes minutes"
  echo "----------------------------------------"

  echo "$file_name,$elapsed_minutes" >> "$OUTPUT_FILE"
done

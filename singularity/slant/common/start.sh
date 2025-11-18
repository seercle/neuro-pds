IMAGE=$1
INPUTS_DIR=$2

OUTPUTS_DIR=./OUTPUTS
OUTPUTS_FILE="$OUTPUTS_DIR/output.csv"

TMP_DIR=./tmp
TMP_TMP="$TMP_DIR/tmp"
TMP_INPUTS="$TMP_DIR/INPUTS"
TMP_OUTPUTS="$TMP_DIR/OUTPUTS"
LOG_FILE="$TMP_OUTPUTS/log.csv"

DATE_FORMAT="%Y-%m-%d_%H:%M:%S"

mkdir -p $OUTPUTS_DIR
mkdir -p $TMP_DIR
mkdir -p $TMP_TMP
mkdir -p $TMP_INPUTS
mkdir -p $TMP_OUTPUTS

echo "filename,elapsed_minutes,file_size_mb" > "$OUTPUTS_FILE"

# Iterate over files in /CUSTOM_INPUTS
find $INPUTS_DIR -type f | sort | while read -r file; do
  if [ -f "$file" ]; then
    # Clear the TMP_TMP, TMP_INPUTS and TMP_OUTPUTS directory
    rm -rf $TMP_TMP/*
    rm -rf $TMP_INPUTS/*
    rm -rf $TMP_OUTPUTS/*

    # Copy the file to TMP_INPUTS
    cp "$file" $TMP_INPUTS/

    bash ./memory.sh "$INTERVAL_SECONDS" "$TMP_OUTPUTS/memory_trace.csv" "$DATE_FORMAT" &
    mem_script_pid=$!

    start_timestamp=$(date +%s)
    echo "$(date -d @$start_timestamp +$DATE_FORMAT): Study of $(basename $file) started."

    # Start singularity
    export SINGULARITY_BINDPATH="$TMP_INPUTS:/INPUTS,$TMP_OUTPUTS:/OUTPUTS"
    singularity exec $IMAGE /extra/run_deep_brain_seg.sh 2>&1 | while IFS= read -r log; do
      timestamp=$(date +$DATE_FORMAT)
      echo "$timestamp,$log" >> "$LOG_FILE"
    done

    end_timestamp=$(date +%s)
    echo "$(date -d @$end_timestamp +$DATE_FORMAT): Study of $(basename $file) ended."

    # Stop the memory monitoring script
    kill $mem_script_pid

    elapsed_seconds=$((end_timestamp - start_timestamp))
    elapsed_minutes=$((elapsed_seconds / 60))
    echo "Elapsed time: $elapsed_minutes minutes"
    echo "----------------------------------------"

    filename=$(basename "$file")

    # Move the content of /TMP_OUTPUTS to the new directory
    mv "$TMP_OUTPUTS" "$OUTPUTS_DIR/$filename"
    mkdir -p "$TMP_OUTPUTS"

    file_size_bytes=$(stat -c%s "$file")
    file_size_mb=$(echo "scale=2; $file_size_bytes / 1024 / 1024" | bc)

    echo "$filename,$elapsed_minutes,$file_size_mb" >> "$OUTPUTS_FILE"
  fi
done

rm -rf $TMP_DIR

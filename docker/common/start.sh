BIN_BASH="/bin/bash"

if [ -z "$INTERVAL_SECONDS" ]; then
  echo "Error: INTERVAL_SECONDS must be provided."
  echo "Usage: $0 <INTERVAL_SECONDS>"
  exit 1
fi

# Iterate over files in /CUSTOM_INPUTS
find /CUSTOM_INPUTS -type f ! -path "*/.*" | while read -r file; do
  if [ -f "$file" ]; then
    # Clear the /INPUTS directory
    rm -rf /INPUTS/*

    # Copy the file to /INPUTS
    cp "$file" /INPUTS/

    # Start the memory monitoring script in the background
    $BIN_BASH /opt/mem.sh "$INTERVAL_SECONDS" &
    MEM_SCRIPT_PID=$!

    # Run the SLANT application
    $BIN_BASH /extra/run_deep_brain_seg.sh

    # Stop the memory monitoring script
    kill $MEM_SCRIPT_PID

    # Create a directory in /CUSTOM_OUTPUTS named after the file
    filename=$(basename "$file")
    output_dir="/CUSTOM_OUTPUTS/$filename"
    mkdir -p "$output_dir"

    # Move the content of /OUTPUTS to the new directory
    mv /OUTPUTS/* "$output_dir/"
  fi
done

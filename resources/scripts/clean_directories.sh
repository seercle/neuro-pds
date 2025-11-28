#!/bin/bash
set -e
for item in *; do
    if [ -d "$item" ]; then
        echo "Processing directory: $item"
        echo "Deleting unwanted files..."
        find "$item" -mindepth 1 -maxdepth 1 -type f -not -name "logs.csv" -not -name "memory_trace.csv" -exec rm -v {} \;

        echo "Deleting subdirectories..."
        find "$item" -mindepth 1 -maxdepth 1 -type d -exec rm -rfv {} \;

        echo "Finished processing directory: $item"
    fi
done

echo "Cleanup complete."

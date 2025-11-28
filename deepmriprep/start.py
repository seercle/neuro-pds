import csv
import os
import sys
from datetime import datetime

from deepmriprep import run_preprocess

if len(sys.argv) < 3:
    print("Usage: python start.py <path_to_data> <path_to_output>")
    sys.exit(1)
data_path = sys.argv[1]
output_dir = sys.argv[2]

output_csv_filename = "output.csv"
# time_format = "%Y-%m-%d_%H:%M:%S"
# memory_csv_filename = "memory_trace.csv"
# logs_csv_filename = "logs.csv"
output_csv_path = os.path.join(output_dir, output_csv_filename)
csv_headers = [
    "filename",
    "elapsed_seconds",
    "file_size_mb",
]

os.makedirs(output_dir, exist_ok=True)

output_csv_exist = os.path.exists(output_csv_path)
output_csv_file = open(output_csv_path, "a", newline="")
csv_writer = csv.writer(output_csv_file)

if not output_csv_exist:
    csv_writer.writerow(csv_headers)
    output_csv_file.flush()

# List only files in data_path
files = [
    file
    for file in os.listdir(data_path)
    if os.path.isfile(os.path.join(data_path, file))
]
files.sort()
for file in files:
    file_path = os.path.join(data_path, file)
    file_output_dir = os.path.join(output_dir, file)
    file_size_bytes = os.path.getsize(file_path)
    file_size_mb = file_size_bytes / (1024 * 1024)
    print(f"Starting preprocessing for {file_path}")

    start = datetime.now()
    run_preprocess([file_path], output_dir=file_output_dir)
    elapsed = datetime.now() - start
    elapsed_seconds = elapsed.total_seconds()

    print(f"Finished preprocessing for {file_path} in {elapsed_seconds}s")
    csv_writer.writerow(
        [
            file,
            elapsed_seconds,
            file_size_mb,
        ]
    )
    output_csv_file.flush()

output_csv_file.close()

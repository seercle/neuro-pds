import csv
import os
import sys
from datetime import datetime

import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

if len(sys.argv) < 2:
    print("Usage: python plot_memory_profile.py <path_to_outputs>")
    sys.exit(1)

# Path to the OUTPUTS directory
outputs_dir = sys.argv[1]
memory_csv_filename = "memory_trace.csv"
output_pdf_filename = "pdf_memory_profile.pdf"
time_format = "%Y-%m-%d_%H:%M:%S"

with PdfPages(output_pdf_filename) as pdf:
    # Iterate over all directories in the OUTPUTS directory
    for subdir in os.listdir(outputs_dir):
        subdir_path = os.path.join(outputs_dir, subdir)
        memory_csv_path = os.path.join(subdir_path, memory_csv_filename)

        # Check if the memory_usage.csv file exists in the directory
        if os.path.isdir(subdir_path) and os.path.exists(memory_csv_path):
            timestamps = []
            mem_usage = []

            # Read the memory_usage.csv file
            with open(memory_csv_path, "r") as file:
                reader = csv.reader(file)
                for row in reader:
                    timestamp, mem_in_gib = row
                    timestamps.append(datetime.strptime(timestamp, time_format))
                    mem_usage.append(float(mem_in_gib))

            # Calculate elapsed time
            start_time = timestamps[0]
            elapsed_time = [(t - start_time).total_seconds() for t in timestamps]

            # Plot the memory usage trace
            plt.figure(figsize=(14, 6))
            plt.plot(elapsed_time, mem_usage, linestyle="-")
            plt.title(f"Memory Usage Over Time: {subdir}")
            plt.xlabel("Elapsed Time (seconds)")
            plt.ylabel("Memory Usage (GiB)")
            plt.grid()

            # Save the current plot to the PDF
            pdf.savefig()
            plt.close()

print(f"All memory usage traces have been saved to {output_pdf_filename}")

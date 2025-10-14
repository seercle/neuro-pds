import csv
import os
from datetime import datetime
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt

# Path to the OUTPUTS directory
outputs_dir = "../docker/OUTPUTS"

# Initialize a PDF file to save all plots
output_pdf = "memory_usage_traces.pdf"
with PdfPages(output_pdf) as pdf:
    # Iterate over all directories in the OUTPUTS directory
    for subdir in os.listdir(outputs_dir):
        subdir_path = os.path.join(outputs_dir, subdir)
        memory_csv = os.path.join(subdir_path, "memory_usage.csv")

        # Check if the memory_usage.csv file exists in the directory
        if os.path.isdir(subdir_path) and os.path.exists(memory_csv):
            timestamps = []
            mem_usage = []

            # Read the memory_usage.csv file
            with open(memory_csv, "r") as file:
                reader = csv.reader(file)
                for row in reader:
                    timestamp, mem_in_gib = row
                    timestamps.append(datetime.strptime(timestamp, "%Y-%m-%d_%H:%M:%S"))
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

print(f"All memory usage traces have been saved to {output_pdf}")

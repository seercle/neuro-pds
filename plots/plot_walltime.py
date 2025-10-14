import os
import csv
from datetime import datetime
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt

# Path to the OUTPUTS directory
outputs_dir = "../docker/OUTPUTS"

# Initialize lists for x and y data
file_sizes = []
walltimes = []

# Iterate over all directories in the OUTPUTS directory
for subdir in os.listdir(outputs_dir):
    subdir_path = os.path.join(outputs_dir, subdir)
    nested_dir_name = subdir.replace(".nii.gz", "")
    memory_csv = os.path.join(subdir_path, "memory_usage.csv")
    nii_file = os.path.join(subdir_path, nested_dir_name, "orig_target.nii.gz")

    # Check if both memory_usage.csv and orig_target.nii.gz exist
    if (
        os.path.isdir(subdir_path)
        and os.path.exists(memory_csv)
        and os.path.exists(nii_file)
    ):
        # Calculate the walltime from memory_usage.csv
        with open(memory_csv, "r") as file:
            reader = csv.reader(file)
            timestamps = [
                datetime.strptime(row[0], "%Y-%m-%d_%H:%M:%S") for row in reader
            ]
            if len(timestamps) >= 2:
                walltime = (
                    timestamps[-1] - timestamps[0]
                ).total_seconds() / 60  # Convert to minutes
                walltimes.append(walltime)

        file_size = os.path.getsize(nii_file) / (
            1024 * 1024
        )  # Convert bytes to megabytes
        file_sizes.append(file_size)

# Create a PDF with the plot
output_pdf = "file_size_vs_walltime.pdf"
with PdfPages(output_pdf) as pdf:
    plt.figure(figsize=(10, 6))
    plt.scatter(walltimes, file_sizes, color="blue")  # Inverted x and y axes
    plt.title("File Size vs Walltime")
    plt.xlabel("Walltime (minutes)")  # Walltime on x-axis
    plt.ylabel("File Size (MB)")  # File size on y-axis
    plt.grid()
    pdf.savefig()
    plt.close()

print(f"The plot has been saved to {output_pdf}")

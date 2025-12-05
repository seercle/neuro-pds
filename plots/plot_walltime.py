import csv
import os
import sys

import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

if len(sys.argv) < 2:
    print("Usage: python plot_walltime.py <path_to_outputs>")
    sys.exit(1)

# Path to the OUTPUTS directory
outputs_dir = sys.argv[1]

# Initialize lists for x and y data
file_sizes = []
walltimes = []

# Path to the output.csv file
output_csv = os.path.join(outputs_dir, "output.csv")

# Read data from output.csv
if os.path.exists(output_csv):
    with open(output_csv, "r") as file:
        reader = csv.reader(file)
        header = next(reader)  # Read the header row

        walltime_header_name = None
        walltime_unit = ""
        walltime_col_index = -1
        file_size_col_index = -1

        if "elapsed_minutes" in header:
            walltime_header_name = "elapsed_minutes"
            walltime_unit = "minutes"
            walltime_col_index = header.index("elapsed_minutes")
        elif "elapsed_seconds" in header:
            walltime_header_name = "elapsed_seconds"
            walltime_unit = "seconds"
            walltime_col_index = header.index("elapsed_seconds")
        else:
            print(
                "Error: Neither 'elapsed_minutes' nor 'elapsed_seconds' found in header."
            )
            sys.exit(1)

        if "file_size_mb" in header:
            file_size_col_index = header.index("file_size_mb")
        else:
            print("Error: 'file_size_mb' not found in header.")
            sys.exit(1)

        if walltime_col_index == -1 or file_size_col_index == -1:
            sys.exit(1)

        for row in reader:
            try:
                walltimes.append(float(row[walltime_col_index]))
                file_sizes.append(float(row[file_size_col_index]))
            except (ValueError, IndexError):
                print(f"Skipping invalid row: {row}")
else:
    print(f"Error: {output_csv} does not exist.")

# Create a PDF with the plot
output_pdf = "pdf_walltime.pdf"
if not walltimes:
    print("No walltime data to plot.")
    sys.exit(1)

with PdfPages(output_pdf) as pdf:
    plt.figure(figsize=(10, 6))
    plt.scatter(walltimes, file_sizes, color="blue")
    plt.title("File Size vs Walltime")
    plt.xlabel(f"Walltime ({walltime_unit})")
    plt.ylabel("File Size (MB)")
    plt.xlim(xmin=0)
    plt.grid()
    pdf.savefig()
    plt.close()

print(f"The plot has been saved to {output_pdf}")

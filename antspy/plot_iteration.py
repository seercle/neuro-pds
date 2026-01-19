import csv
import os
import sys

import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

if len(sys.argv) < 2:
    print("Usage: python plot_iteration.py <path_to_output_dir>")
    sys.exit(1)

# Path to the OUTPUTS directory
outputs_dir = sys.argv[1]

# Initialize lists for x and y data
file_sizes = []
iterations = []

# Path to the output.csv file
output_csv = os.path.join(outputs_dir, "output.csv")

# Read data from output.csv
if os.path.exists(output_csv):
    with open(output_csv, "r") as file:
        reader = csv.reader(file)
        header = next(reader)  # Read the header row

        iteration_col_index = -1
        file_size_col_index = -1

        if "iterations" in header:
            iteration_col_index = header.index("iterations")
        else:
            print("Error: 'iteration' not found in header.")
            sys.exit(1)

        if "file_size_mb" in header:
            file_size_col_index = header.index("file_size_mb")
        else:
            print("Error: 'file_size_mb' not found in header.")
            sys.exit(1)

        for row in reader:
            try:
                iterations.append(int(row[iteration_col_index]))
                file_sizes.append(float(row[file_size_col_index]))
            except (ValueError, IndexError):
                print(f"Skipping invalid row: {row}")
else:
    print(f"Error: {output_csv} does not exist.")

# Create a PDF with the plot
output_pdf = "pdf_iteration.pdf"
if not iterations:
    print("No iteration data to plot.")
    sys.exit(1)

with PdfPages(output_pdf) as pdf:
    plt.figure(figsize=(10, 6))
    plt.scatter(iterations, file_sizes, color="blue")
    plt.title("File Size vs Iteration")
    plt.xlabel("Iteration (count)")
    plt.ylabel("File Size (MB)")
    max_iteration = max(iterations)
    plt.xlim(0, max_iteration * 1.5)
    plt.grid()
    pdf.savefig()
    plt.close()

print(f"The plot has been saved to {output_pdf}")

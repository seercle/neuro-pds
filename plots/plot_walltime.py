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
        next(reader)  # Skip the header row
        for row in reader:
            if len(row) == 3:
                filename, elapsed_minutes, file_size_mb = row
                try:
                    walltimes.append(float(elapsed_minutes))
                    file_sizes.append(float(file_size_mb))
                except ValueError:
                    print(f"Skipping invalid row: {row}")
else:
    print(f"Error: {output_csv} does not exist.")

# Create a PDF with the plot
output_pdf = "pdf_walltime.pdf"
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

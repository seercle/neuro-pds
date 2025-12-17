import argparse
import csv
import sys
from collections import Counter

import matplotlib.pyplot as plt


def analyze_elapsed_times(input_csv_file, output_pdf_file, time_column):
    """
    Reads a CSV file, extracts time data from a specified column, rounds them to the nearest
    integer, and outputs a histogram of the counts for each rounded time unit.

    Args:
        input_csv_file (str): The path to the input CSV file.
        output_pdf_file (str): The path to the output PDF file for the histogram.
        time_column (str): The name of the column containing elapsed time data (e.g., 'elapsed_minutes').
    """
    elapsed_time_data = []

    try:
        with open(input_csv_file, mode="r", newline="") as infile:
            reader = csv.DictReader(infile)
            _actual_time_column = time_column
            if time_column not in reader.fieldnames:
                alternative_column = (
                    "elapsed_seconds"
                    if time_column == "elapsed_minutes"
                    else "elapsed_minutes"
                )
                if alternative_column in reader.fieldnames:
                    print(
                        f"Warning: '{time_column}' column not found. Using '{alternative_column}' instead.",
                        file=sys.stderr,
                    )
                    _actual_time_column = alternative_column
                else:
                    print(
                        f"Error: Neither '{time_column}' nor '{alternative_column}' column found in {input_csv_file}",
                        file=sys.stderr,
                    )
                    sys.exit(1)

            for row in reader:
                try:
                    # Convert to float, then round to the nearest integer
                    time_value = float(row[_actual_time_column])
                    rounded_time = round(time_value)
                    elapsed_time_data.append(rounded_time)
                except ValueError:
                    print(
                        f"Warning: Could not parse '{_actual_time_column}' value '{row[_actual_time_column]}' in row for filename '{row.get('filename', 'N/A')}', skipping.",
                        file=sys.stderr,
                    )
                    continue
    except FileNotFoundError:
        print(f"Error: Input CSV file '{input_csv_file}' not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred while reading the CSV file: {e}", file=sys.stderr)
        sys.exit(1)

    if not elapsed_time_data:
        print(f"No valid '{_actual_time_column}' data found to generate a histogram.")
        return

    # Calculate the histogram
    histogram = Counter(elapsed_time_data)

    # Sort the histogram by time unit for a cleaner output
    sorted_histogram_items = sorted(histogram.items())

    # Prepare data for matplotlib
    minutes_bins = [item[0] for item in sorted_histogram_items]
    counts = [item[1] for item in sorted_histogram_items]

    # Create the histogram plot
    plt.figure(figsize=(10, 6))
    plt.bar(minutes_bins, counts, color="skyblue", width=0.8, edgecolor="black")

    # Add labels and title
    # Determine the unit for the label based on the actual column used
    unit = "Minutes" if _actual_time_column == "elapsed_minutes" else "Seconds"

    plt.xlabel(f"Elapsed {unit} (Rounded to Nearest Integer)")
    plt.ylabel("Number of Rows (Count)")
    plt.title(f"Histogram of Elapsed {unit}")
    plt.xticks(minutes_bins)  # Ensure all bins are labeled
    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()  # Adjust layout to prevent labels from overlapping

    # Save the plot as a PDF
    plt.savefig(output_pdf_file)
    print(f"Histogram saved to {output_pdf_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate a histogram of 'elapsed_minutes' from a CSV file, rounded to the nearest integer."
    )
    parser.add_argument(
        "input_csv_file",
        help="The path to the input CSV file containing time data.",
    )
    parser.add_argument(
        "--time_column",
        default="elapsed_minutes",
        choices=["elapsed_minutes", "elapsed_seconds"],
        help="The name of the column containing elapsed time data (default: elapsed_minutes).",
    )
    parser.add_argument(
        "output_pdf_file",
        help="The path to the output PDF file where the histogram will be saved.",
    )

    args = parser.parse_args()

    analyze_elapsed_times(args.input_csv_file, args.output_pdf_file, args.time_column)

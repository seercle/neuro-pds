import argparse
import csv
import sys
from collections import Counter

import matplotlib.pyplot as plt


def analyze_data_distribution(input_csv_file, output_pdf_file, data_column):
    """
    Reads a CSV file, extracts numerical data from a specified column, rounds them to the nearest
    integer, and outputs a histogram of the counts for each value.

    Args:
        input_csv_file (str): The path to the input CSV file.
        output_pdf_file (str): The path to the output PDF file for the histogram.
        data_column (str): The name of the column containing data (e.g., 'iterations', 'elapsed_minutes').
    """
    extracted_data = []

    try:
        with open(input_csv_file, mode="r", newline="") as infile:
            reader = csv.DictReader(infile)

            if data_column not in reader.fieldnames:
                print(
                    f"Error: Column '{data_column}' not found in {input_csv_file}. Available columns: {', '.join(reader.fieldnames)}",
                    file=sys.stderr,
                )
                sys.exit(1)

            for row in reader:
                try:
                    val_str = row[data_column]
                    if not val_str:
                        continue

                    value = float(val_str)
                    rounded_value = round(value)
                    extracted_data.append(rounded_value)
                except ValueError:
                    print(
                        f"Warning: Could not parse '{data_column}' value '{row[data_column]}' in row for filename '{row.get('filename', 'N/A')}', skipping.",
                        file=sys.stderr,
                    )
                    continue
    except FileNotFoundError:
        print(f"Error: Input CSV file '{input_csv_file}' not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred while reading the CSV file: {e}", file=sys.stderr)
        sys.exit(1)

    if not extracted_data:
        print(f"No valid '{data_column}' data found to generate a histogram.")
        return

    # Calculate the histogram
    histogram = Counter(extracted_data)

    # Sort the histogram by value for a cleaner output
    sorted_histogram_items = sorted(histogram.items())

    # Prepare data for matplotlib
    bins = [item[0] for item in sorted_histogram_items]
    counts = [item[1] for item in sorted_histogram_items]

    # Create the histogram plot
    plt.figure(figsize=(10, 6))
    plt.bar(bins, counts, color="skyblue", width=0.8, edgecolor="black")

    # Add labels and title
    if "time" in data_column or "seconds" in data_column or "minutes" in data_column:
        unit = "Time Units"
        if "seconds" in data_column:
            unit = "Seconds"
        elif "minutes" in data_column:
            unit = "Minutes"
        xlabel = f"Elapsed {unit} (Rounded)"
        title = f"Histogram of Elapsed {unit}"
    elif "iterations" in data_column:
        xlabel = "Number of Iterations"
        title = "Histogram of Iterations"
    else:
        xlabel = f"{data_column} (Rounded)"
        title = f"Histogram of {data_column}"

    plt.xlabel(xlabel)
    plt.ylabel("Number of Rows (Count)")
    plt.title(title)

    # Only set xticks if there aren't too many unique values, otherwise it gets crowded
    if len(bins) < 50:
        plt.xticks(bins)

    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()

    # Save the plot as a PDF
    plt.savefig(output_pdf_file)
    print(f"Histogram saved to {output_pdf_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate a histogram of a specific column (e.g., 'iterations') from a CSV file."
    )
    parser.add_argument(
        "input_csv_file",
        help="The path to the input CSV file containing data.",
    )
    parser.add_argument(
        "output_pdf_file",
        help="The path to the output PDF file where the histogram will be saved.",
    )
    parser.add_argument(
        "--column",
        default="iterations",
        help="The name of the column containing data to plot (default: iterations).",
    )

    args = parser.parse_args()

    analyze_data_distribution(args.input_csv_file, args.output_pdf_file, args.column)

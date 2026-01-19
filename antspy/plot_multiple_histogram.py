import argparse
import csv
import os
import sys

import matplotlib.pyplot as plt
import numpy as np


def analyze_multiple_distributions(input_csv_files, output_pdf_file, data_column):
    datasets = []
    source_labels = []
    all_filenames = set()

    # Determine labels for legend
    filenames_only = [os.path.basename(f) for f in input_csv_files]
    use_parent_dir_labels = len(set(filenames_only)) < len(filenames_only)

    print(f"Processing {len(input_csv_files)} input files...")

    for csv_file in input_csv_files:
        current_file_data = {}

        # Generate label for the legend
        if use_parent_dir_labels:
            parent = os.path.basename(os.path.dirname(os.path.abspath(csv_file)))
            label = f"{parent}/{os.path.basename(csv_file)}"
        else:
            label = os.path.basename(csv_file)
        source_labels.append(label)

        try:
            with open(csv_file, mode="r", newline="") as infile:
                reader = csv.DictReader(infile)

                # Check for required columns
                if "filename" not in reader.fieldnames:
                    print(
                        f"Error: Column 'filename' not found in {csv_file}. Skipping file.",
                        file=sys.stderr,
                    )
                    datasets.append({})
                    continue

                if data_column not in reader.fieldnames:
                    print(
                        f"Warning: Column '{data_column}' not found in {csv_file}. Skipping file.",
                        file=sys.stderr,
                    )
                    datasets.append({})
                    continue

                for row in reader:
                    fname = row["filename"]
                    val_str = row[data_column]

                    if fname and val_str:
                        try:
                            val = float(val_str)
                            current_file_data[fname] = val
                            all_filenames.add(fname)
                        except ValueError:
                            pass
        except FileNotFoundError:
            print(f"Error: File '{csv_file}' not found.", file=sys.stderr)
            datasets.append({})
            continue
        except Exception as e:
            print(f"Error reading '{csv_file}': {e}", file=sys.stderr)
            datasets.append({})
            continue

        datasets.append(current_file_data)

    if not all_filenames:
        print("No valid data found in any input file. Exiting.", file=sys.stderr)
        sys.exit(1)

    # Sort filenames alphabetically for consistent X-axis
    sorted_filenames = sorted(list(all_filenames))
    num_files = len(sorted_filenames)
    num_datasets = len(datasets)

    # Dynamic figure size: ensure enough width for many bars
    fig_width = max(12, num_files * 0.4)
    plt.figure(figsize=(fig_width, 8))

    # Setup X-axis positions
    x = np.arange(num_files)
    total_width = 0.8  # Total width of the group of bars
    bar_width = total_width / num_datasets

    # Calculate starting offset to center the group on the tick
    start_offset = -total_width / 2 + bar_width / 2

    colors = plt.cm.viridis(np.linspace(0, 0.9, num_datasets))

    for i, data_dict in enumerate(datasets):
        # Extract values in the order of sorted_filenames
        y_values = [data_dict.get(fname, 0) for fname in sorted_filenames]

        plt.bar(
            x + start_offset + i * bar_width,
            y_values,
            width=bar_width,
            label=source_labels[i],
            color=colors[i],
            alpha=0.85,
            edgecolor="black",
            linewidth=0.5,
        )

    # Formatting
    plt.xlabel("Filename", fontweight="bold")

    # Determine Y-axis label based on column name
    if "iterations" in data_column:
        ylabel = "Iteration Count"
        title = "Iterations per File"
    elif "time" in data_column or "seconds" in data_column:
        ylabel = "Time (s)"
        title = "Elapsed Time per File"
    else:
        ylabel = data_column.capitalize()
        title = f"{data_column.capitalize()} per File"

    plt.ylabel(ylabel, fontweight="bold")
    plt.title(title, fontsize=14)

    # Set X-ticks
    plt.xticks(x, sorted_filenames, rotation=90, ha="center", fontsize=8)

    # Add legend
    plt.legend(title="Source", bbox_to_anchor=(1.0, 1.0), loc="upper left")

    plt.grid(axis="y", linestyle="--", alpha=0.3)
    plt.tight_layout()

    try:
        plt.savefig(output_pdf_file)
        print(f"Plot saved to {output_pdf_file}")
    except Exception as e:
        print(f"Error saving plot to '{output_pdf_file}': {e}", file=sys.stderr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate a grouped bar chart comparing values from multiple CSV files."
    )
    parser.add_argument(
        "--inputs",
        nargs="+",
        required=True,
        help="Paths to the input CSV files.",
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Path to the output PDF file.",
    )
    parser.add_argument(
        "--column",
        default="iterations",
        help="The name of the column containing data to plot (default: iterations).",
    )

    args = parser.parse_args()

    analyze_multiple_distributions(args.inputs, args.output, args.column)

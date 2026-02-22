import argparse
import os
import sys

import matplotlib.pyplot as plt
import pandas as pd


def analyze_iteration_vs_walltime(input_csv, output_file):
    print(f"Processing input file: {input_csv}")

    if not os.path.exists(input_csv):
        print(f"Error: File '{input_csv}' not found.", file=sys.stderr)
        sys.exit(1)

    try:
        df = pd.read_csv(input_csv)

        required_columns = ["iterations", "elapsed_seconds"]
        if not all(col in df.columns for col in required_columns):
            print(
                f"Error: CSV {input_csv} must contain columns: {required_columns}.",
                file=sys.stderr,
            )
            sys.exit(1)

        grouped_df = df.groupby("iterations")["elapsed_seconds"].mean().reset_index()
        grouped_df = grouped_df.sort_values("iterations")

        if grouped_df.empty:
            print(f"Error: No valid data in {input_csv}.", file=sys.stderr)
            sys.exit(1)

        plt.figure(figsize=(10, 6))
        plt.plot(
            grouped_df["iterations"],
            grouped_df["elapsed_seconds"],
            marker="o",
            linestyle="-",
        )

        plt.title("Average Elapsed Time vs Iteration Count")
        plt.xlabel("Iteration Count")
        plt.ylabel("Average Elapsed Seconds")
        plt.xticks(grouped_df["iterations"][::1])
        plt.grid(True)

        plt.savefig(output_file)
        print(f"Plot saved to {output_file}")

    except Exception as e:
        print(f"Error processing '{input_csv}': {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate a plot of Iteration Count vs Average Elapsed Seconds from a single CSV file."
    )
    parser.add_argument(
        "input_csv",
        help="Path to the input CSV file.",
    )
    parser.add_argument(
        "output_file",
        help="Path to the output image file (e.g., .png, .pdf).",
    )

    args = parser.parse_args()

    analyze_iteration_vs_walltime(args.input_csv, args.output_file)

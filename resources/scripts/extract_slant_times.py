import argparse
import math
import os
import re
import sys


def extract_slant_times(input_directory, output_csv_file):
    """
    Extracts preprocessing, segmentation, and postprocessing times from slant's logs.csv
    files within subdirectories of the given input directory.

    Args:
        input_directory (str): The path to the main directory containing subdirectories
                                with logs.csv files.
        output_csv_file (str): The path to the output CSV file where results will be saved.
    """
    if not os.path.isdir(input_directory):
        print(f"Error: Input directory '{input_directory}' not found.", file=sys.stderr)
        sys.exit(1)

    with open(output_csv_file, "w") as outfile:
        outfile.write(
            "subdirectory,preprocessing_time_seconds,segmentation_time_seconds,postprocessing_time_seconds\n"
        )

        preprocessing_times = []
        segmentation_times = []
        postprocessing_times = []

        # Get all immediate subdirectories, filter, and sort them by name
        subdirs = sorted(
            [
                d
                for d in os.listdir(input_directory)
                if os.path.isdir(os.path.join(input_directory, d))
            ]
        )

        for subdir_name in subdirs:
            subdir_path = os.path.join(input_directory, subdir_name)
            log_file_path = os.path.join(subdir_path, "logs.csv")

            if not os.path.isfile(log_file_path):
                print(
                    f"Warning: logs.csv not found in {subdir_path}. Skipping.",
                    file=sys.stderr,
                )
                continue

            preprocessing_time = "N/A"
            segmentation_time = "N/A"
            postprocessing_time = "N/A"

            try:
                with open(log_file_path, "r") as log_file:
                    log_content = log_file.read()

                    # Regex patterns to find the times
                    # \K is a PCRE feature to reset the match start. In Python, we use a capturing group.
                    preprocessing_match = re.search(
                        r"preprocessing time: (\d+)", log_content
                    )
                    segmentation_match = re.search(
                        r"segmentation time: (\d+)", log_content
                    )
                    postprocessing_match = re.search(
                        r"postprocessing time: (\d+)", log_content
                    )

                    if preprocessing_match:
                        preprocessing_time = preprocessing_match.group(1)
                        preprocessing_times.append(int(preprocessing_time))
                    if segmentation_match:
                        segmentation_time = segmentation_match.group(1)
                        segmentation_times.append(int(segmentation_time))
                    if postprocessing_match:
                        postprocessing_time = postprocessing_match.group(1)
                        postprocessing_times.append(int(postprocessing_time))

            except IOError as e:
                print(f"Error reading {log_file_path}: {e}", file=sys.stderr)
                continue

            outfile.write(
                f"{subdir_name},{preprocessing_time},{segmentation_time},{postprocessing_time}\n"
            )

    print(f"Extraction complete. Results saved to {output_csv_file}\n")

    def calculate_stats(name, data_list):
        if not data_list:
            print(f"No valid data points found for {name}.")
            return

        avg = sum(data_list) / len(data_list)
        # Calculate standard deviation if there's more than one data point
        std_dev = 0.0
        if len(data_list) > 1:
            std_dev = math.sqrt(sum((x - avg) ** 2 for x in data_list) / len(data_list))

        print(f"{name} - Average: {avg:.2f}s, Std Dev: {std_dev:.2f}s")

    print("--- Time Statistics ---")
    calculate_stats("Preprocessing Time", preprocessing_times)
    calculate_stats("Segmentation Time", segmentation_times)
    calculate_stats("Postprocessing Time", postprocessing_times)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Extract preprocessing, segmentation, and postprocessing times from slant's logs.csv files."
    )
    parser.add_argument(
        "input_directory",
        help="The main directory containing subdirectories with logs.csv files.",
    )
    parser.add_argument(
        "output_csv_file",
        help="The path to the output CSV file where results will be saved.",
    )

    args = parser.parse_args()

    extract_slant_times(args.input_directory, args.output_csv_file)

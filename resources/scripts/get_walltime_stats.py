import csv
import statistics
import sys


def calculate_stats_from_csv(file_path):
    """
    Calculates the average and standard deviation of the second column
    (either 'elapsed_minutes' or 'elapsed_seconds') from a CSV file.

    Args:
        file_path (str): The path to the CSV file.
    """
    values = []
    column_name = None

    try:
        with open(file_path, mode="r", newline="") as csvfile:
            reader = csv.reader(csvfile)
            header = next(reader)  # Read the header row

            # Determine the column index
            if "elapsed_minutes" in header:
                column_name = "elapsed_minutes"
                col_index = header.index("elapsed_minutes")
            elif "elapsed_seconds" in header:
                column_name = "elapsed_seconds"
                col_index = header.index("elapsed_seconds")
            else:
                print(
                    f"Error: Neither 'elapsed_minutes' nor 'elapsed_seconds' column found in {file_path}"
                )
                return

            for row in reader:
                if len(row) > col_index:
                    try:
                        values.append(float(row[col_index]))
                    except ValueError:
                        print(
                            f"Warning: Skipping non-numeric value '{row[col_index]}' in column '{column_name}'"
                        )
                else:
                    print(f"Warning: Skipping row with insufficient columns: {row}")

        if not values:
            print(
                f"No valid numeric data found in column '{column_name}' to calculate statistics."
            )
            return

        average = statistics.mean(values)
        std_dev = statistics.stdev(values)

        print(f"Statistics for column '{column_name}':")
        print(f"  Average: {average:.2f}")
        print(f"  Standard Deviation: {std_dev:.2f}")

    except FileNotFoundError:
        print(f"Error: The file '{file_path}' was not found.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python calculate_stats.py <path_to_csv_file>")
        sys.exit(1)

    input_csv_path = sys.argv[1]
    calculate_stats_from_csv(input_csv_path)

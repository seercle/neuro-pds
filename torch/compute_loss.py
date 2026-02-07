import argparse
import sys

import numpy as np
import pandas as pd


def compute_metrics(
    pred_csv, truth_csv, pred_col="predicted_iterations", truth_col="iterations"
):
    print(f"Loading predictions from: {pred_csv}")
    print(f"Loading ground truth from: {truth_csv}")
    print(f"Using prediction column: {pred_col}")
    print(f"Using ground truth column: {truth_col}")

    try:
        df_pred = pd.read_csv(pred_csv)
        df_truth = pd.read_csv(truth_csv)
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading CSV files: {e}")
        sys.exit(1)

    if "filename" not in df_pred.columns:
        print(
            f"Error: Prediction CSV missing 'filename' column. Found: {df_pred.columns.tolist()}"
        )
        sys.exit(1)

    if pred_col not in df_pred.columns:
        print(
            f"Error: Prediction CSV missing '{pred_col}' column. Found: {df_pred.columns.tolist()}"
        )
        sys.exit(1)

    if "filename" not in df_truth.columns:
        print(
            f"Error: Truth CSV missing 'filename' column. Found: {df_truth.columns.tolist()}"
        )
        sys.exit(1)

    if truth_col not in df_truth.columns:
        print(
            f"Error: Truth CSV missing '{truth_col}' column. Found: {df_truth.columns.tolist()}"
        )
        sys.exit(1)

    merged_df = pd.merge(
        df_pred, df_truth, on="filename", how="inner", suffixes=("_pred", "_truth")
    )

    if merged_df.empty:
        print("Error: No matching filenames found between prediction and truth CSVs.")
        sys.exit(1)

    n_samples = len(merged_df)
    print(f"Matched {n_samples} samples.")

    y_pred = merged_df[pred_col].values
    y_true = merged_df[truth_col].values

    mse = np.mean((y_pred - y_true) ** 2)

    me = np.mean(abs(y_pred - y_true))

    print("-" * 30)
    print(f"MSE (Mean Squared Error): {mse:.6f}")
    print(f"ME  (Mean Error)        : {me:.6f}")
    print("-" * 30)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Compute MSE and ME between prediction and ground truth CSVs."
    )
    parser.add_argument(
        "pred_csv",
        help="Path to the CSV file containing predictions (must have 'filename' and 'predicted_iterations').",
    )
    parser.add_argument(
        "truth_csv",
        help="Path to the CSV file containing ground truth (must have 'filename' and 'iterations').",
    )
    parser.add_argument(
        "--pred_col",
        default="predicted_iterations",
        help="Column name for predictions (default: predicted_iterations)",
    )
    parser.add_argument(
        "--truth_col",
        default="iterations",
        help="Column name for ground truth (default: iterations)",
    )

    args = parser.parse_args()

    compute_metrics(args.pred_csv, args.truth_csv, args.pred_col, args.truth_col)

import glob
import os
import re
import sys
import tempfile
import time

import ants
import pandas as pd

if len(sys.argv) < 3:
    print("Usage: python start.py <path_to_data> <path_to_output>")
    sys.exit(1)
data_path = sys.argv[1]
output_dir = sys.argv[2]

output_filename = "output.csv"

os.makedirs(output_dir, exist_ok=True)


def run_atropos():
    image_files = sorted(glob.glob(os.path.join(data_path, "*.nii*")))

    if not image_files:
        print(f"No files found in {data_path}!")
        return

    performance_log = []
    print(f"Found {len(image_files)} T1w images.")

    for i, img_path in enumerate(image_files):
        filename = os.path.basename(img_path)
        print(f"\n--- Processing [{i + 1}/{len(image_files)}]: {filename} ---")

        try:
            # 1. Load Image
            img = ants.image_read(img_path)

            # Safety Check: T1w must be 3D
            if img.dimension != 3:
                print(f"   > Skipping: Expected 3D image, found {img.dimension}D.")
                continue

            print("   > Atropos Segmentation...")

            sys.stdout.flush()
            original_stdout_fd = os.dup(sys.stdout.fileno())

            with tempfile.TemporaryFile(mode="w+") as tfile:
                try:
                    os.dup2(tfile.fileno(), sys.stdout.fileno())
                    seg = ants.atropos(
                        a=img,
                        m="[0.3,1x1x1]",  # 3D smoothing
                        c="[50,1e-5]",  # Loop up to 50 times to find tissue boundaries
                        i="kmeans[3]",  # Initialize with K-Means
                        x=ants.get_mask(img),
                        verbose=1,
                    )
                finally:
                    sys.stdout.flush()
                    os.dup2(original_stdout_fd, sys.stdout.fileno())
                    os.close(original_stdout_fd)

                tfile.seek(0)
                output_log = tfile.read()

            # print(output_log)

            # Parse last iteration number
            iterations = 0
            matches = re.findall(r"Iteration (\d+) \(of \d+\)", output_log)
            if matches:
                iterations = int(matches[-1])
            print(f"   > Iterations: {iterations}")

            # Parse elapsed time
            time_seg = 0.0
            matches = re.findall(r"Elapsed time: ([\d.]+)", output_log)
            if matches:
                time_seg = float(matches[-1])
            print(f"   > Elapsed Time: {time_seg:.2f}s")

            # Save Output
            output_path = os.path.join(output_dir, f"seg_{filename}")
            ants.image_write(seg["segmentation"], output_path)

            performance_log.append(
                {
                    "filename": filename,
                    "elapsed_seconds": round(time_seg, 2),
                    "file_size_mb": round(os.path.getsize(img_path) / (1024 * 1024), 2),
                    "iterations": iterations,
                }
            )

        except Exception as e:
            print(f"   > Error: {e}")
            performance_log.append(
                {
                    "filename": filename,
                    "elapsed_seconds": 0,
                    "file_size_mb": 0,
                    "iterations": 0,
                }
            )

        # Save CSV Report
        df = pd.DataFrame(performance_log)
        output_path = os.path.join(output_dir, output_filename)
        df.to_csv(output_path, index=False)

    print(f"\nBatch completed. Data saved to {output_filename}")


if __name__ == "__main__":
    run_atropos()

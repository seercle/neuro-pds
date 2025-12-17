import glob
import os
import sys
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


def run_t1_pipeline():
    # Look for T1 files (common namings)
    # If your files are just .nii.gz, change this to '*.nii*'
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

            start_total = time.time()

            # 2. Pre-processing: Truncate Intensity
            # (Removes extreme bright pixels/outliers common in T1w raw data)
            print("   > Step 1: Denoise & Truncate...")
            img = ants.iMath(img, "TruncateIntensity", 0.01, 0.99)
            img = ants.denoise_image(img, noise_model="Rician")

            # 3. Brain Extraction (Skull Stripping)
            # For T1w, we need a clean mask or Atropos will classify the skull as white matter.
            print("   > Step 2: Creating Brain Mask...")
            # mask = ants.get_mask(img)
            mask = ants.get_mask(img, low_thresh=None, high_thresh=None, cleanup=2)

            # 4. N4 Bias Field Correction (Variable Time)
            # We set convergence to be strict. Noisy scanners will take longer here.
            print("   > Step 3: N4 Bias Correction...")
            start_n4 = time.time()
            img_n4 = ants.n4_bias_field_correction(
                img, mask=mask, convergence={"iters": [50, 50, 50, 50], "tol": 1e-7}
            )
            time_n4 = time.time() - start_n4

            # 5. Atropos Segmentation (Variable Time)
            # 3D Neighborhood (1x1x1)
            # 3 Tissue Classes (CSF, GM, WM)
            print("   > Step 4: Atropos Segmentation...")
            start_seg = time.time()
            seg = ants.atropos(
                a=img_n4,
                m="[0.5,1x1x1]",  # 3D smoothing
                c="[50,1e-5]",  # Loop up to 50 times to find tissue boundaries
                i="kmeans[3]",  # Initialize with K-Means
                x=mask,
                verbose=1,
            )
            time_seg = time.time() - start_seg

            total_elapsed = time.time() - start_total
            print(
                f"   > Total Time: {total_elapsed:.2f}s (N4: {time_n4:.2f}s, Seg: {time_seg:.2f}s)"
            )

            # Save Output
            output_path = os.path.join(output_dir, f"seg_{filename}")
            ants.image_write(seg["segmentation"], output_path)

            performance_log.append(
                {
                    "Filename": filename,
                    "Time_Total": round(total_elapsed, 2),
                    "Time_N4": round(time_n4, 2),
                    "Time_Atropos": round(time_seg, 2),
                    "Status": "Success",
                }
            )

        except Exception as e:
            print(f"   > Error: {e}")
            performance_log.append(
                {"Filename": filename, "Time_Total": 0, "Status": f"Failed: {str(e)}"}
            )

    # Save CSV Report
    df = pd.DataFrame(performance_log)
    df.to_csv(output_filename, index=False)
    print(f"\nBatch completed. Data saved to {output_filename}")

    print(f"\nBatch completed. Data saved to {output_filename}")


if __name__ == "__main__":
    run_t1_pipeline()

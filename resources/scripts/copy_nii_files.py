import argparse
import os
import shutil
import sys
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(
        description="Recursively list, sort, and copy .nii.gz files within a specified index range."
    )
    parser.add_argument("source_dir", type=Path, help="Path to the source input directory")
    parser.add_argument("dest_dir", type=Path, help="Path to the destination output directory")
    parser.add_argument("x", type=int, help="Start index (inclusive)")
    parser.add_argument("y", type=int, help="End index (exclusive)")

    args = parser.parse_args()

    if not args.source_dir.exists():
        print(f"Error: Source directory '{args.source_dir}' does not exist.", file=sys.stderr)
        sys.exit(1)

    if not args.source_dir.is_dir():
        print(f"Error: '{args.source_dir}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    print(f"Scanning '{args.source_dir}' for .nii.gz files...")
    nii_files = []
    for root, _, files in os.walk(args.source_dir):
        for file in files:
            if file.endswith(".nii.gz"):
                nii_files.append(Path(root) / file)

    nii_files.sort(key=lambda p: str(p))

    total_files = len(nii_files)
    print(f"Found {total_files} .nii.gz files.")

    start_index = args.x
    end_index = args.y

    if start_index < 0:
        print("Warning: Start index x is negative, setting to 0.")
        start_index = 0

    if end_index > total_files:
        print(f"Warning: End index y ({end_index}) is larger than total files ({total_files}), setting to {total_files}.")
        end_index = total_files

    if start_index >= end_index:
        print(f"No files to copy. The range [{start_index}, {end_index}) is empty or invalid.")
        return

    files_to_copy = nii_files[start_index:end_index]
    print(f"Processing range [{start_index}, {end_index}). Copying {len(files_to_copy)} files to '{args.dest_dir}'...")

    if not args.dest_dir.exists():
        print(f"Creating destination directory '{args.dest_dir}'...")
        args.dest_dir.mkdir(parents=True, exist_ok=True)

    success_count = 0
    for src_path in files_to_copy:
        dest_path = args.dest_dir / src_path.name

        try:
            shutil.copy2(src_path, dest_path)
            success_count += 1
        except Exception as e:
            print(f"Error copying '{src_path}' to '{dest_path}': {e}", file=sys.stderr)

    print(f"Operation complete. Successfully copied {success_count} files.")

if __name__ == "__main__":
    main()

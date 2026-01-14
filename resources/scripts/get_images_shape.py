import os
import sys

import nibabel as nib


def main():
    if len(sys.argv) < 2:
        print("Usage: python get_images_shape.py <directory_path>")
        sys.exit(1)

    directory_path = sys.argv[1]

    if not os.path.isdir(directory_path):
        print(f"Error: {directory_path} is not a valid directory")
        sys.exit(1)

    for filename in os.listdir(directory_path):
        filepath = os.path.join(directory_path, filename)
        if os.path.isdir(filepath):
            continue

        try:
            img = nib.load(filepath)
            print(f"File: {filename}, Shape: {img.shape}")
            print(f"Resolution: {img.header.get_zooms()}")

        except Exception as e:
            print(f"Could not process {filename}: {e}")

        except Exception as e:
            print(f"Could not process {filename}: {e}")


if __name__ == "__main__":
    main()

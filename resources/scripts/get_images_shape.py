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

    shapes = set()
    for root, dirs, files in os.walk(directory_path):
        files.sort()
        for filename in files:
            filepath = os.path.join(root, filename)

            try:
                img = nib.load(filepath)
                print(f"File: {filepath}, Shape: {img.shape}")
                print(f"Resolution: {img.header.get_zooms()}")
                shapes.add(img.shape)

            except Exception as e:
                print(f"Could not process {filepath}: {e}")
    print(f"Unique shapes found: {shapes}")


if __name__ == "__main__":
    main()

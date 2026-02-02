import argparse
import glob
import os

import nibabel as nib
import numpy as np
import pandas as pd
import torch.nn as nn
import torch.nn.functional as F
from monai.transforms import (
    Compose,
    EnsureChannelFirst,
    LoadImage,
    Resize,
    ScaleIntensity,
)
from sklearn.model_selection import train_test_split
from torch.utils.data import DataLoader, Dataset
from tqdm import tqdm

import torch


class NiftiDataset(Dataset):
    def __init__(self, data_dir, filenames, labels_dict):
        self.data_dir = data_dir
        self.filenames = filenames
        self.labels_dict = labels_dict

        self.transforms = Compose(
            [
                LoadImage(image_only=True),
                EnsureChannelFirst(),  # Adds channel dim: (1, D, H, W)
                ScaleIntensity(),  # Normalize intensities to [0, 1]
                Resize((64, 64, 64)),  # Resize to fixed size to fit GPU
            ]
        )

    def __len__(self):
        return len(self.filenames)

    def __getitem__(self, idx):
        filename = self.filenames[idx]
        img_path = os.path.join(self.data_dir, filename)

        image = self.transforms(img_path)

        label = self.labels_dict.get(filename)

        if label is None:
            raise ValueError(f"No label found for {filename}")

        return image, torch.tensor(label, dtype=torch.float32)


class NiftiPredictor(nn.Module):
    def __init__(self):
        super(NiftiPredictor, self).__init__()

        # Convolutional Block
        self.features = nn.Sequential(
            # Conv Layer 1
            nn.Conv3d(1, 32, kernel_size=3, padding=1),
            nn.BatchNorm3d(32),
            nn.ReLU(),
            nn.MaxPool3d(2),  # Output: 32 x 32 x 32
            # Conv Layer 2
            nn.Conv3d(32, 64, kernel_size=3, padding=1),
            nn.BatchNorm3d(64),
            nn.ReLU(),
            nn.MaxPool3d(2),  # Output: 16 x 16 x 16
            # Conv Layer 3
            nn.Conv3d(64, 128, kernel_size=3, padding=1),
            nn.BatchNorm3d(128),
            nn.ReLU(),
            nn.MaxPool3d(2),  # Output: 8 x 8 x 8
            # Conv Layer 4
            nn.Conv3d(128, 256, kernel_size=3, padding=1),
            nn.BatchNorm3d(256),
            nn.ReLU(),
            nn.MaxPool3d(2),  # Output: 4 x 4 x 4
        )

        # Regression Head
        self.regressor = nn.Sequential(
            nn.Flatten(),
            nn.Linear(256 * 4 * 4 * 4, 128),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(128, 1),  # Output single scalar
        )

    def forward(self, x):
        x = self.features(x)
        x = self.regressor(x)
        return x


def train_model(data_dir, filenames, labels_dict):
    # 1. Setup Data
    # Split train/test
    train_files, val_files = train_test_split(filenames, test_size=0.2, random_state=42)

    train_dataset = NiftiDataset(
        data_dir, train_files.reset_index(drop=True), labels_dict
    )
    val_dataset = NiftiDataset(data_dir, val_files.reset_index(drop=True), labels_dict)

    train_loader = DataLoader(train_dataset, batch_size=8, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=8, shuffle=False)

    # 2. Setup Model
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = NiftiPredictor().to(device)

    criterion = nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)

    # 3. Loop
    num_epochs = 50
    patience = 5
    best_val_loss = float("inf")
    patience_counter = 0
    best_model_state = None

    for epoch in range(num_epochs):
        # Training
        model.train()
        train_loss = 0
        progress_bar = tqdm(train_loader, desc=f"Epoch {epoch + 1}/{num_epochs}")

        for images, labels in progress_bar:
            images, labels = images.to(device), labels.to(device)

            optimizer.zero_grad()
            outputs = model(images).squeeze(1)  # Shape [Batch]

            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            train_loss += loss.item()
            progress_bar.set_postfix(loss=loss.item())

        avg_train_loss = train_loss / len(train_loader)

        # Validation
        model.eval()
        val_loss = 0
        with torch.no_grad():
            for images, labels in val_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images).squeeze(1)
                loss = criterion(outputs, labels)
                val_loss += loss.item()

        avg_val_loss = val_loss / len(val_loader)

        print(
            f"Epoch {epoch + 1}/{num_epochs}, "
            f"Train Loss: {avg_train_loss:.4f}, "
            f"Val Loss: {avg_val_loss:.4f}"
        )

        # Early Stopping Check
        if avg_val_loss < best_val_loss:
            best_val_loss = avg_val_loss
            patience_counter = 0
            best_model_state = model.state_dict()
        else:
            patience_counter += 1
            if patience_counter >= patience:
                print(f"Early stopping triggered at epoch {epoch + 1}")
                break

    if best_model_state is not None:
        model.load_state_dict(best_model_state)

    return model


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="")
    parser.add_argument(
        "--data_dir",
        required=True,
        help="Paths to the data files directory",
    )
    parser.add_argument(
        "--csv",
        required=True,
        help="Paths to the CSV dataset",
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Path to save the trained model",
    )

    args = parser.parse_args()
    data_dir_path = args.data_dir
    csv_file_path = args.csv
    output_path = args.output

    df = pd.read_csv(csv_file_path)

    labels_map = dict(zip(df["filename"], df["iterations"]))
    model = train_model(data_dir_path, df["filename"], labels_map)

    torch.save(model.state_dict(), output_path)
    print(f"Model saved to {output_path}")

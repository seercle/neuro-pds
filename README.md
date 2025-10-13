# Performance Analysis and Walltime Prediction for Neuroscience Applications

## Walkthrough
If this is your first time using this repository, please follow the steps below:
1. **Clone the repository**:
   ```bash
   git clone https://github.com/seercle/neuro-pds.git
   cd neuro-pds
   ```
2. **Set up the dataset**:
   - Ensure you have `git-annex` installed.
   - Initialize the raiders dataset submodule:
     ```bash
     git submodule update --init
     ```
   - Import the raiders dataset into the docker inputs directory (this will download approximately 4.8GB of data):
     ```bash
     cd datasets
     bash import_raiders.sh
     ```
3. **Build the Docker image**:
   - Navigate to the docker directory and build the CPU docker image:
     ```bash
     cd docker
     bash build_images.sh
     ```
4. **Run the Docker container**:
   - For CPU:
     ```bash
     cd docker/cpu
     docker compose up -d
     ```
5. **Trace memory profile**:
   - Edit the CSV file path in `plots/plot_memory_profile.py`.
   - Run the script:
     ```bash
     cd plots
     python plot_memory_profile.py
     ```
## References:

- [Ana Gainaru, Brice Goglin, Valentin Honoré, Guillaume Pallez. Profiles of upcoming HPC Applications and their Impact on Reservation Strategies. IEEE Transactions on Parallel and Distributed Systems, 2021, 32 (5), pp.1178-1190. ⟨10.1109/TPDS.2020.3039728⟩. ⟨hal-03010676⟩](https://inria.hal.science/hal-03010676v1/)

- SLANT papers:

  - [Yuankai Huo, Zhoubing Xu, Yunxi Xiong, Katherine Aboud, Parasanna Parvathaneni, Shunxing Bao, Camilo Bermudez, Susan M. Resnick, Laurie E. Cutting, and Bennett A. Landman. "3D whole brain segmentation using spatially localized atlas network tiles" NeuroImage 2019](https://arxiv.org/pdf/1806.00546)

  - [Yuankai Huo, Zhoubing Xu, Katherine Aboud, Parasanna Parvathaneni, Shunxing Bao, Camilo Bermudez, Susan M. Resnick, Laurie E. Cutting, and Bennett A. Landman. "Spatially Localized Atlas Network Tiles Enables 3D Whole Brain Segmentation" In International Conference on Medical Image Computing and Computer-Assisted Intervention, MICCAI 2018](https://www.sciencedirect.com/science/article/pii/S1053811919302307)

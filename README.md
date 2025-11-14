# Performance Analysis and Walltime Prediction for Neuroscience Applications

## Walkthrough
If this is your first time using this repository, please follow the steps below:
1. **Clone the repository**:
   ```bash
   git clone https://github.com/seercle/neuro-pds.git
   cd neuro-pds
   ```
2. **Set up the dataset**:
   - Download the raiders dataset in the directory (this will download approximately 4.8GB of data):
     ```bash
     cd datasets
     bash import_raiders.sh
     ```
3. **Build and run the Docker image**:
  - 1. **Build the Docker images**:
    - Navigate to the docker directory and build the docker images (this will download approximately 32GB of data):
      ```bash
      cd docker
      bash build_images.sh
      ```
  - 2. **Run the Docker container**:
    - Choose a version of SLANT to run between `cpu_v1_0`, `cpu_v1_1`, `gpu_v1_0` and `gpu_v1_1`
    - You may want to edit the path to the dataset in `docker/[slant_version]/Dockerfile`
    - Run the selection version:
      ```bash
      cd docker/[slant_version]
      docker compose up -d
      ```
4. **Trace memory profile (Docker only)**:
   - Edit the `outputs_dir` path in `docker/plot_memory_profile.py` to correspond to the chosen SLANT version.
   - Run the script:
     ```bash
     cd docker
     python plot_memory_profile.py
     ```
5. **Build and run Singularity**:
  - 1. **Build the Singularity image**:
    - Choose a version of SLANT to run between `cpu_v1_0`, `cpu_v1_1`, `gpu_v1_0` and `gpu_v1_1`
    - Navigate to that directory and build the corresponding image (this will create an image of approximately 8GB of data):
      ```bash
      cd singularity/[slant_version]
      bash build.sh
      ```
  - 2. **Run the Singularity container**:
    - You may want to change the path to the dataset in `singularity/[slant_version]/run.sh`
    ```bash
    cd singularity/[slant_version]
    bash run.sh
    ```
6. **Trace walltime profile (Docker and Singularity)**:
  - Choose a SLANT version you have previously ran Docker or Singularity on
  - Edit the `output_dir` path in `plots/plot_walltime.py` to correspond
  - Plot the walltime:
    ```bash
    cd plots
    python plot_walltime.py
    ```

## References:

- [Ana Gainaru, Brice Goglin, Valentin Honoré, Guillaume Pallez. Profiles of upcoming HPC Applications and their Impact on Reservation Strategies. IEEE Transactions on Parallel and Distributed Systems, 2021, 32 (5), pp.1178-1190. ⟨10.1109/TPDS.2020.3039728⟩. ⟨hal-03010676⟩](https://inria.hal.science/hal-03010676v1/)

- SLANT papers:

  - [Yuankai Huo, Zhoubing Xu, Yunxi Xiong, Katherine Aboud, Parasanna Parvathaneni, Shunxing Bao, Camilo Bermudez, Susan M. Resnick, Laurie E. Cutting, and Bennett A. Landman. "3D whole brain segmentation using spatially localized atlas network tiles" NeuroImage 2019](https://arxiv.org/pdf/1806.00546)

  - [Yuankai Huo, Zhoubing Xu, Katherine Aboud, Parasanna Parvathaneni, Shunxing Bao, Camilo Bermudez, Susan M. Resnick, Laurie E. Cutting, and Bennett A. Landman. "Spatially Localized Atlas Network Tiles Enables 3D Whole Brain Segmentation" In International Conference on Medical Image Computing and Computer-Assisted Intervention, MICCAI 2018](https://www.sciencedirect.com/science/article/pii/S1053811919302307)

- MaCRUISE papers:

  - Yuankai Huo, Andrew J. Plassard, Aaron Carass, Susan M. Resnick, Dzung L. Pham, Jerry L. Prince, and Bennett A. Landman. "Consistent cortical reconstruction and multi-atlas brain segmentation." NeuroImage 138 (2016): 197-210.

  - Yuankai Huo, Aaron Carass, Susan M. Resnick, Dzung L. Pham, Jerry L. Prince, and Bennett A. Landman. "Combining multi-atlas segmentation with brain surface estimation." In Medical Imaging 2016: Image Processing, vol. 9784, p. 97840E. International Society for Optics and Photonics, 2016.

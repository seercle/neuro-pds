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
3. **Build the Docker images**:
  - Navigate to the `dockerfiles` directory and build the docker images (this will download approximately 52GB of data):
    ```bash
    cd dockerfiles
    bash build_all.sh
    ```
  - If you only need certain images, you can build them individually using the `build_all.sh` script as a reference.
4. **Run the SLANT Docker image**
  - Choose a version of SLANT to run between `cpu_v1_0`, `cpu_v1_1`, `gpu_v1_0` and `gpu_v1_1`
  - Edit the docker compose with the selected version. Either in `docker/slant/compose_cpu.yml` for CPU versions, or `docker/slant/compose_gpu.yml` for GPU versions (NVIDIA GPUs only)
  - You may want to edit things like the path to the dataset or the location of the outputs directory. If you have followed the previous steps, editing is not necessary as the default paths should work.
  - Run the selection version:
    ```bash
    cd docker/slant
    docker compose -f compose_[cpu|gpu].yml up -d
    ```
5. **Run the MaCRUISE Docker image**
  - Edit the docker compose in `docker/macruise/compose.yml` with the CUSTOM_INPUTS volume pointing to the output directory of the previous SLANT run. If you did not edit the output directory in the SLANT docker compose, you should not need to change anything.
  - Run the application:
    ```bash
    cd docker/macruise
    docker compose -f compose.yml up -d 
    ```
6. **Trace memory profiles (Docker only)**:
   - Choose an application you have previously ran Docker on (SLANT or MaCRUISE) and get the path to its output directory
   - Run the script (requires `matplotlib`):
     ```bash
     cd docker
     python plot_memory_profile.py [path_to_the_output_directory_of_the_application]
     ```
    - This should create a file named `pdf_memory_profile.pdf` in the current directory.
7. **Build and run SLANT with Singularity**:
  - We provide a Singularity definition file for each version of SLANT. Since Singularity is not a fully isolated container system like Docker, running SLANT with Singularity may error during the execution.
  - 1. **Build the SLANT Singularity image**:
    - Choose a version of SLANT to run between `cpu_v1_0`, `cpu_v1_1`, `gpu_v1_0` and `gpu_v1_1`
    - Navigate to that directory and build the corresponding image (this will create an image of approximately 8GB of data):
      ```bash
      cd singularity/slant/[slant_version]
      bash build.sh
      ```
  - 2. **Run the SLANT Singularity container**:
    - You may want to change the path to the dataset in `singularity/slant/[slant_version]/run.sh`
      ```bash
      cd singularity/slant/[slant_version]
      bash run.sh
      ```
8. **Trace walltime profile (Docker and Singularity)**:
  - Choose a SLANT/MaCRUISE version you have previously ran Docker or Singularity on, and get the path to its output directory
  - Plot the walltime:
    ```bash
    cd plots
    python plot_walltime.py [path_to_the_output_directory_of_the_application]
    ```

## References:

- [Ana Gainaru, Brice Goglin, Valentin Honoré, Guillaume Pallez. Profiles of upcoming HPC Applications and their Impact on Reservation Strategies. IEEE Transactions on Parallel and Distributed Systems, 2021, 32 (5), pp.1178-1190. ⟨10.1109/TPDS.2020.3039728⟩. ⟨hal-03010676⟩](https://inria.hal.science/hal-03010676v1/)

- SLANT papers:

  - [Yuankai Huo, Zhoubing Xu, Yunxi Xiong, Katherine Aboud, Parasanna Parvathaneni, Shunxing Bao, Camilo Bermudez, Susan M. Resnick, Laurie E. Cutting, and Bennett A. Landman. "3D whole brain segmentation using spatially localized atlas network tiles" NeuroImage 2019](https://arxiv.org/pdf/1806.00546)

  - [Yuankai Huo, Zhoubing Xu, Katherine Aboud, Parasanna Parvathaneni, Shunxing Bao, Camilo Bermudez, Susan M. Resnick, Laurie E. Cutting, and Bennett A. Landman. "Spatially Localized Atlas Network Tiles Enables 3D Whole Brain Segmentation" In International Conference on Medical Image Computing and Computer-Assisted Intervention, MICCAI 2018](https://www.sciencedirect.com/science/article/pii/S1053811919302307)

- MaCRUISE papers:

  - [Yuankai Huo, Andrew J. Plassard, Aaron Carass, Susan M. Resnick, Dzung L. Pham, Jerry L. Prince, and Bennett A. Landman. "Consistent cortical reconstruction and multi-atlas brain segmentation." NeuroImage 138 (2016): 197-210](https://pubmed.ncbi.nlm.nih.gov/27184203/)

  - [Yuankai Huo, Aaron Carass, Susan M. Resnick, Dzung L. Pham, Jerry L. Prince, and Bennett A. Landman. "Combining multi-atlas segmentation with brain surface estimation." In Medical Imaging 2016: Image Processing, vol. 9784, p. 97840E. International Society for Optics and Photonics, 2016](https://pmc.ncbi.nlm.nih.gov/articles/PMC4845967/)

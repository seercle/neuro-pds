#import "@preview/charged-ieee:0.1.4": ieee
#show: ieee.with(
  title: [Performance Analysis and Walltime Prediction for Neuroscience Applications],
  abstract: [
    Recent advancements in High-Performance Computing (HPC), Big Data, and Artificial Intelligence (AI) have driven an unprecedented demand for computational resources in neuroscience.
    However, efficiently utilizing these resources remains a challenge due to the complexity of modern computing systems and the diverse nature of neuroscience applications.
    In this paper, we present a comprehensive performance analysis of several neuroscience applications, focusing on their execution time and memory footprint, and
    compare them across different system configurations.
    Finally, we develop a model to predict the execution time of one of these applications based on their input parameters and system configurations.
  ],
  authors: (
    (
      name: "Axel Vivenot",
      email: "axel.vivenot@telecom-paris.fr"
    ),
    (
      name: "Valentin Delis",
      email: "valentin.delis@ensiie.fr"
    ),
  ),
  index-terms: ("Stochastic application", "Execution time", "Memory footprint"),
  bibliography: bibliography("refs.bib", style:"association-for-computing-machinery"),
  figure-supplement: [Fig.],
)

#show figure.caption: set align(center)

= Introduction

When designing an application, it is crucial to understand its performance consistency relative to input parameters. In the context of High-Performance Computing (HPC), resources are typically allocated based on walltime estimates. Consequently, accurate prediction models are essential for efficient resource management and cost reduction. This is particularly critical for stochastic applications where execution time varies significantly. With the increasing complexity of neuroscience applications driven by AI and Big Data, understanding these performance characteristics has become paramount.

In this paper, we present a comprehensive performance analysis of several neuroscience applications, focusing on characterizing their execution time and memory footprint relative to input data.

= Platform

All experiments were conducted on a server node with the following specifications:
- CPUs: 2 AMD EPYC 7502 32-Core Processors (64 threads \@ 2.50GHz)
- RAM: 504 GiB
- GPU: NVIDIA Quadro RTX 5000

To minimize interference, we ensured that no other significant user processes were active during experiments.
Background system processes consumed approximately 1% of CPU and 6% of RAM (\~30 GiB) on average.

We measured application memory usage using two methods:
- For Docker-based applications, we queried `/sys/fs/cgroup/memory.current` to obtain precise container memory usage.
- For native applications, we utilized `vmstat` to monitor system-wide memory fluctuations, as granular per-process tracking was not feasible for these specific workflows.

= Spatially Localized Atlas Network Tiles (SLANT)

This study begins with a specific brain segmentation application called SLANT (Spatially Localized Atlas Network Tiles)@slant2019 @slant2018.
SLANT uses a fully convolutional network (FCN) to segment 3D MRI brain scans into different anatomical regions.
The segmentation is performed in three main steps: preprocessing, segmentation using a deep learning model,
and postprocessing to generate the output result.
SLANT exists in two versions: SLANT v1.0 and SLANT v1.1, with both versions supporting CPU and GPU modes.
We will focus here on the overlapped version of SLANT: SLANT27, which uses 27 overlapped network tiles for segmentation.

== Replicating Previous Results

In a 2020 study _Profiles of upcoming HPC Applications and their Impact on Reservation Strategies_@hpc2020,
the authors analyzed the performance of the SLANT algorithm for brain segmentation.
They observed that the execution time of SLANT varied significantly depending on the input data, with a walltime of 125min#sym.plus.minus\30%.
This result was obtained using a Singularity@singularity image of SLANT v1.0 in CPU mode, running on a machine with two
Intel Xeon E5-2680v3 processors (12core \@ 2,5 GHz) with an unspecified amount of RAM.
We can find the exact dataset used to perform the DRD experiments in the GitHub repository associated with the study@hpc2020-github.
This is a dataset containing 87 images of fMRI (Functional magnetic resonance imaging) scans from
the Dartmouth Raiders Dataset (DRD)@drd.
Each is a 4D scan, with 326 pictures at resolution of 80x80x41 voxels.
While SLANT is designed for 3D T1-weighted MRI scans, the DRD dataset works as input for the application,
noting that the segmentation output itself is not clinically valid for this data type.

These findings are particularly compelling as they demonstrate significant variability in execution time correlated with input data.
Replicating these results would allow us to model and predict this variability based on input parameters, thereby optimizing resource allocation.

To replicate the previous results, we ran the same SLANT CPU v1.0 Singularity implementation
on our platform using the same DRD fMRI dataset.

We ran the SLANT algorithm in three different configurations:
- Using 1 thread
- Using 48 threads, with 12 cores per CPU, similarly to the machine used in the previous study
- Using all 128 threads

#figure(
  caption: [Mean and Standard Deviation Walltime of SLANT CPU on Singularity],
  table(
    columns: 3,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Nb of threads][Mean time (min)][Std Dev (min)],
    [1], [106.33], [0.55],
    [48], [106.79], [4.12],
    [128], [108.12], [4.11],
  )
) <tab:slant_cpu_singularity_walltime>

#figure(
  image("images/walltime_slant_cpu_singularity_single_cpu.svg"),
  caption: "SLANT CPU Singularity Walltime vs fMRI number of scans for one threads"
)
#figure(
  image("images/walltime_slant_cpu_singularity_some_cpus.svg"),
  caption: "SLANT CPU Singularity Walltime vs fMRI number of scans for 48 threads"
)
#figure(
  image("images/walltime_slant_cpu_singularity_all_cpus.svg"),
  caption: "SLANT CPU Singularity Walltime vs fMRI number of scans for all 128 threads"
)

We observe in @tab:slant_cpu_singularity_walltime a walltime of around 107 minutes regardless of the number of threads used,
with a very low standard deviation for all number of threads, with the (still small) highest standard deviation of 48 and 128 threads probably
coming from the inter-process communication overhead.

#figure(
  caption: [Mean and Standard Deviation walltime of each step for SLANT CPU on Singularity (in seconds)],
  table(
    columns: 7,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Nb of threads][Preprocessing (mean)][Preprocessing (std)][Segmentation (mean)][Segmentation (std)][Postprocessing (mean)][Postprocessing (std)],
    [1], [931], [25], [4820], [11], [588], [8],
    [48], [836], [39], [4906], [212], [660], [55],
    [128], [856], [41], [4924], [78], [705], [224],
  )
) <tab:slant_cpu_singularity_times>
We also decomposed the walltime into its three main steps: preprocessing, segmentation and postprocessing in @tab:slant_cpu_singularity_times.
Again, we can see that the standard deviation is very low compared to the mean time, showing that the execution
time is very consistent regardless of the input.
These results are thus very different from the previous study, where the walltime varied significantly depending on the input data.

#figure(
  image("images/memory_profile_slant_cpu_singularity_all_cpus.svg"),
  caption: "SLANT CPU Singularity memory profile for all 128 threads"
) <fig:walltime_slant_cpu_singularity_all_cpus>

We plotted an example of the memory profile in @fig:walltime_slant_cpu_singularity_all_cpus
obtained when running SLANT CPU on Singularity with all 128 threads.
Notice the Y-axis does not start at 0 due to the high background memory usage,
however this usage does not impact the performance of the application.
We see that the difference between the base memory usage and the peak memory usage is around 42GiB, which is consistent with the previous study.
The shape of the memory profile is also very similar, with the preprocessing step consisting of 3 separates peaks,
followed by a long segmentation step with 27 peaks, corresponding to the network parameterization of SLANT-27,
and finally a postprocessing step with 1 peak.

This replication attempt shows that while we could not replicate the execution time variability observed in the previous study,
we could replicate the memory footprint profile of the SLANT CPU Singularity implementation.
This shows that our platform seem to be running similar
jobs as the previous study, but with unidentified system variables leading to a variable time in their case.
From our testing with different number of threads, we can also conclude that the time variation
in the previous study was not due to the number of threads used.

#figure(
  caption: [Mean and Standard Deviation walltime of each step for SLANT CPU on Docker (in seconds)],
  table(
  )
) <tab:slant_cpu_docker_times>

// Ajouter le tableau des résultats sous Docker

#figure(
  image("images/memory_profile_slant_cpu_docker_all_cpus.svg"),
  caption: "SLANT CPU Docker memory profile for all 128 threads"
) <fig:memory_profile_slant_cpu_docker_all_cpus>

In case the paper @hpc2020 was using Docker instead of Singularity, we also ran the SLANT CPU Docker in the same 3 configurations.
We observe in @tab:slant_cpu_docker_times that the walltime is again very consistent regardless of the number of threads used, just
being a bit higher than the Singularity version.
Similarly, the memory profile in @fig:memory_profile_slant_cpu_docker_all_cpus
is also very similar to the Singularity implementation, with peak usage being
a bit higher than the Singularity version, probably due to Docker's overhead.
Note that, due to using Docker, we now can plot the absolute memory usage starting at 0.

This shows that the runtime used (Docker or Singularity) does not impact the non-variability of the execution time we observed,
contrary to the previous study. The variability shown in the previous study cannot come from the dual-cpu nature of the platform used, and
must thus come from other factors, such as the hardware used or some unknown configuration.
We performed the same study on several other machines, and have found again no significant variability in execution time,
showing that the variability observed in the previous study is most likely not the normal behaviour of SLANT CPU.

== Other SLANT Versions

In case the previous study used by mistake either a different version or the GPU mode of SLANT,
we used the same dataset to run SLANT on the following versions and configurations:
- SLANT v1.0 GPU Docker
- SLANT v1.1 CPU Docker
- SLANT v1.1 GPU Docker

#figure(
  caption: [Mean and Standard Deviation Walltime of SLANT],
  table(
    columns: 5,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Mode][Version][Thread count][Mean time (min)][Std Dev (min)],
  )
) <tab:slant_other_walltime>

To ensure the discrepancy wasn't due to version mismatches or hardware acceleration differences,
we extended our benchmarking to SLANT v1.0 (GPU) and v1.1 (CPU and GPU). Across all configurations,
the execution time remained remarkably consistent, reinforcing our conclusion that the software version
is not the primary source of the previously observed variability. This consistency persists regardless
of the underlying hardware acceleration or specific minor version updates.

== Slant algorithm

The SLANT algorithm is composed of three steps:
1. Preprocessing
2. Segmentation
3. Postprocessing

SLANT relies, for the segmentation part, on a 3D U-Net@unet deep learning model trained on T1-weighted MRI scans.
When running SLANT as a user, the segmentation step is performed by using the pre-trained model provided by the authors, without training or fine-tuning.
Thus, the segmentation step is deterministic, meaning that for a given input, the output will always be the same.
The previous study@hpc2020 showed time variations, with the standard deviation being 8.5% of the mean time for the segmentation step,
which is substantially higher than our results, but can still be considered low.
However, the variation in the previous study is more important in the other steps, with the standard
deviation being 25% of the mean time in preprocessing and 50% in postprocessing respectively@hpc2020.
These steps seem to be more affected by input variability, which is unexpected compared to our results in @tab:slant_cpu_singularity_times.
The postprocessing step in particular is finishing with an `antsRegistration` step from the ANTs library@ants
, that allows for `1000x1000x1000` maximum steps.
This step could be the source of variation of the postprocessing in the previous study, as the number of iterations required for convergence could vary depending on the input data.
However, we could not observe this variability in our experiments.

Similarly, the preprocessing step involves a rigid registration that takes almost all the preprocessing time in our runs.
This step is performed using `reg_aladin` tool from the NiftyReg library@niftyreg. This tool uses an iterative
approach to perform the registration, and the number of iterations required for convergence could vary depending on the input data.
Again, we could not observe this variability in our experiments.

= deepmriprep

Given the consistent performance of SLANT in our environment, we expanded our scope to `deepmriprep`@deepmriprep, another prominent neuroscience application.
As a deep learning-based MRI preprocessing pipeline, it offers a comparable workload structure but employs different underlying algorithms, allowing us to verify if our observations were specific to SLANT or indicative of a broader trend in containerized neuroimaging tools.
The tool can perform multiple preprocessing steps, including:
- brain extraction
- affine registration
- tissue segmentation
- nonlinear registration
- smoothing

The application uses a combination of traditional image processing techniques and deep learning models to achieve its results.
deepmriprep is a Voxel-Based Morphometry (VBM) tool, meaning that it focuses on analyzing the differences in brain anatomy at the voxel level.
However, it can also perform Region-Based Morphometry (RBM) by registering the preprocessed images to a standard atlas.
Whether a deep learning model is used depends on the operation being performed.

#figure(
  caption: [deepmriprep preprocessing steps and methods used],
  table(
    columns: 3,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Preprocessing step][Method used][Deep learning?],
    [brain extraction],[CNN], [yes],
    [affine registration],[iterative], [no],
    [tissue segmentation],[3D UNet], [yes],
    [nonlinear registration],[3D Unet],[yes],
    [smoothing],[convolution],[no],
  )
)

deepmriprep provides three main output types:
- `rbm` (region-based morphometry): standard preprocessing, then atlas registration
- `vbm` (voxel-based morphometry): standard preprocessing, then tiv, mwp1, mwp2, s6mwp1 and s6mwp2
- `all`: perform all preprocessing steps

We ran deepmriprep in CPU mode on our platform using the same fMRI dataset from the Dartmouth Raiders Dataset (DRD).
Similarly to SLANT, deepmriprep is expecting 3D, T1-weighted MRI scans as input,
but can still process the 4D fMRI scans from the DRD dataset, probably by processing the first 3D scan only.
We ran the algorithm using different number of threads (1 and 128) and different output types (`rbm`, `vbm`, and `all`).

#figure(
  caption: [Mean and Standard Deviation walltime of deepmriprep in seconds],
  table(
    columns: 5,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Type][Nb of threads][Output type][Walltime (mean)][Walltime (std)],
    [cpu],[1], [all], [326.5], [2.3],
    [cpu],[128], [all], [85.6], [1.6],
    [cpu],[128], [rbm], [51.1], [1.0],
  )
)

We observe in the results that the walltime is very consistent regardless of the number of threads used or the output type,
with a standard deviation being always below 2% of the mean time.
This shows that deepmriprep is also not affected by input variability when using the fMRI dataset from DRD, similarly to our study of SLANT.

This result is expected for the deep learning-based steps of deepmriprep, as they are deterministic for a given input.
However, some of the other steps, such as affine registration and smoothing, do not use deep learning models and could thus be affected by input variability.
The fact that we do not observe any significant variability in execution time suggests that these steps are also not significantly affected by input variability,
at least for the fMRI dataset used in this study.

= ANTS

Finally, we investigated the Advanced Normalization Tools (ANTs).
Unlike the containerized deep learning applications discussed previously, ANTs relies strictly on traditional iterative algorithms for segmentation (specifically Expectation-Maximization).
In theory, this algorithmic approach introduces greater potential for runtime variability, as convergence depends heavily on the specific characteristics of the input data.
The suite includes:
- image registration
- segmentation
- template building
- brain extraction
- and a lot more

We focused our study on the brain segmentation functionality of ANTs, which can be used to segment brain MRI scans into different anatomical regions.
ANTs' Atropos algorithm performs segmentation using an iterative approach based on the Expectation-Maximization (EM) algorithm.
The algorithm iteratively refines the segmentation by updating the class probabilities and the model parameters until convergence
We ran ANTs in CPU mode on our platform but, unlike SLANT and deepmriprep, we used a 3D T1-weighted MRI dataset from the OASIS-3 dataset@oasis3.

#figure(
  caption: [Atropos parameters],
  table(
    columns: 2,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[parameter][value],
    [smoothness],[0.5,1x1x1],
    [threshold],[1e-5],
    [max iterations],[50],
    [initialization],[kmeans(3)],
  )
)

We ran the Atropos algorithm using the parameters listed in the table above,
which are commonly used for brain segmentation tasks.
The most important parameter here is the threshold value, which determines the convergence criteria of the algorithm.
The algorithm stops when the log-likelihood change between iterations is below this threshold.
This means that the condition, at step n, for stopping the algorithm is:
$
  |"likelihood"_n - "likelihood"_(n-1)| < "threshold"
$
It is this treshold value, in combination with the max iteration parameter, that can lead to variability in execution time,
as the number of iterations required for convergence can vary depending on the input data.
If the threshold is set too low, the algorithm may take a long time to converge, leading to maximum iteration being reached.
Conversely, if the threshold is set too high, the algorithm may converge instantly, leading to no variability in execution time.
We chose a threshold value of 1e-5, which is a common value used in practice, and a maximum of 50 iterations, which is a higher value than
the maximum number of iterations we observed in practice with our dataset.

#import "@preview/charged-ieee:0.1.4": ieee
#show: ieee.with(
  title: [Performance Analysis and Walltime Prediction for Neuroscience Applications],
  abstract: [
    Recent advancements in High-Performance Computing (HPC), Big Data, and Artificial Intelligence (AI) have driven an unprecedented demand for computational resources in neuroscience.
    However, efficiently utilizing these resources remains a challenge due to the complexity of modern computing systems and the diverse nature of neuroscience applications.
    This problem is exacerbated in neuroscience applications, where users are often not experts in computer science or HPC, making it difficult to optimize resource allocation and job scheduling.
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

When designing an application, it is crucial to understand its performance consistency relative to
input parameters. In the context of High-Performance Computing (HPC), resources are typically allocated
based on walltime estimates. To schedule jobs efficiently and minimize wait times, users often provide an estimate of the expected execution time.
Consequently, accurate prediction models are essential for efficient resource management
and cost reduction. This prediction depends on many factors, including input data, system configuration,
hardware, and software implementation.
This is particularly critical for stochastic applications where execution time varies significantly.
With the increasing complexity of neuroscience applications driven by AI and Big Data, understanding these performance
characteristics has become more important than ever.

In this paper, we present a comprehensive performance analysis of several neuroscience applications,
focusing on characterizing their execution time and memory footprint relative to input data.

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

#figure(
  caption: [SLANT output example],
  image("images/slant_example.jpg")
)

The segmentation is performed in three main steps: preprocessing, segmentation using a deep learning model,
and postprocessing to generate the output result.
SLANT exists in two versions: SLANT v1.0 and SLANT v1.1, with both versions supporting CPU and GPU modes.
We will focus here on the overlapped version of SLANT: SLANT27, which uses 27 overlapped network tiles for segmentation.

== Replicating Previous Results

In a 2020 study _Profiles of upcoming HPC Applications and their Impact on Reservation Strategies_@hpc2020,
the authors analyzed the performance of the SLANT algorithm for brain segmentation.
They observed that the execution time of SLANT varied significantly depending on the input data, with a walltime of 125 min #sym.plus.minus 30%.
This result was obtained using a Singularity@singularity image of SLANT v1.0 in CPU mode, running on a machine with two
Intel Xeon E5-2680v3 processors (12core \@ 2,5 GHz) with an unspecified amount of RAM.
We can find the exact dataset used to perform the DRD experiments in the git repository associated with the study@hpc2020-git.
This is a dataset containing 87 images of fMRI (Functional magnetic resonance imaging) scans from
the Dartmouth Raiders Dataset (DRD)@drd.
Each is a 4D scan, with between 326 and 344 pictures at a resolution of 80x80x41 voxels.
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
  caption: "SLANT CPU Singularity Walltime vs fMRI number of scans for one thread"
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
with a very low standard deviation for all number of threads, with the highest (though still small) standard deviation occurring at 48 and 128 threads, probably
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
The shape of the memory profile is also very similar, with the preprocessing step consisting of 3 separate peaks,
followed by a long segmentation step with 27 peaks, corresponding to the network parameterization of SLANT-27,
and finally a postprocessing step with 1 peak.

#figure(
  image("images/previous_walltime.png"),
  caption: "2020 study result for SLANT CPU Singularity walltime on two separate datasets"
) <fig:previous_walltime>
#figure(
  image("images/previous_memory_profile.png"),
  caption: "2020 study result for SLANT CPU Singularity memory profile on an DRD data"
) <fig:previous_memory_profile>

This replication attempt shows that, while we could not replicate the execution time variability observed in the previous study (@fig:previous_walltime),
we could replicate the memory footprint profile of the SLANT CPU Singularity implementation (@fig:previous_memory_profile).
This shows that our platform seems to be running similar
jobs as the previous study, but with unidentified system variables leading to a variable time in their case.
From our testing with different number of threads, we can also conclude that the time variation
in the previous study was not due to the number of threads used.

#figure(
  caption: [Mean and Standard Deviation walltime of each step for SLANT CPU on Docker (in seconds)],
  table(
    columns: 7,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Nb of threads][Preprocessing (mean)][Preprocessing (std)][Segmentation (mean)][Segmentation (std)][Postprocessing (mean)][Postprocessing (std)],
    [128], [1324], [51], [4919], [59], [1150], [44],
  )
) <tab:slant_cpu_docker_times>

#figure(
  image("images/memory_profile_slant_cpu_docker_all_cpus.svg"),
  caption: "SLANT CPU Docker memory profile for all 128 threads"
) <fig:memory_profile_slant_cpu_docker_all_cpus>

In case the paper @hpc2020 was using Docker instead of Singularity, we also ran the SLANT CPU Docker in the same 3 configurations.
We observe in @tab:slant_cpu_docker_times that the walltime is again very consistent.
The mean walltime is a bit higher than the Singularity implementation for the preprocessing and postprocessing phases,
but the standard deviation remains very low compared to the mean time for all three steps.
Similarly, the memory profile in @fig:memory_profile_slant_cpu_docker_all_cpus
is also very similar to the Singularity implementation, with peak usage being
a bit higher than the Singularity version, probably due to Docker's overhead.
Note that, due to using Docker, we now can plot the absolute memory usage starting at 0.

We can compare the memory profile of SLANT CPU Docker in @fig:memory_profile_slant_cpu_docker_all_cpus
with the Singularity version in @fig:walltime_slant_cpu_singularity_all_cpus.
We see that the application stays at a very low memory usage at the beginning of the preprocessing step,
for around 600 seconds.
Similarly, at the beginning and also at the end of the postprocessing step,
the memory usage is also very low for around 1000 seconds in total.
Although we do not have an explanation for it, this particular behaviour of Docker could be the source of the higher
mean walltime observed in @tab:slant_cpu_docker_times compared to @tab:slant_cpu_singularity_times.

This shows that the runtime used (Docker or Singularity) does not impact the non-variability of the execution time we observed,
contrary to the previous study. The variability shown in the previous study cannot come from the dual-cpu nature of the platform used, and
must thus come from other factors, such as the hardware used or some unknown configuration.
We performed the same study on several other machines, and have found again no significant variability in execution time,
showing that the variability observed in the previous study is most likely not the normal behaviour of SLANT CPU.

== Causes of variability and non-variability

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
    [gpu], [1.0], [128], [59.40], [1.89],
    [cpu], [1.1], [128], [137.14], [1.01],
    [gpu], [1.1], [128], [60.19], [3.49],
  )
) <tab:slant_other_walltime>

To ensure the discrepancy wasn't due to version mismatches or hardware acceleration differences,
we extended our benchmarking to SLANT v1.0 (GPU) and v1.1 (CPU and GPU) in @tab:slant_other_walltime. Across all configurations,
the execution time remained remarkably consistent, reinforcing our conclusion that the software version
is not the primary source of the previously observed variability. This consistency persists regardless
of the underlying hardware acceleration or specific minor version updates. We also ran SLANT in various versions using a subset of the
OASIS-3 T1 image dataset@oasis3, and observed the same non-variability in execution time, showing that the variability observed
in the previous study is not due to the specific dataset used, nor due to the resolution of the input images.
Thus, we decided to look deeper into the SLANT algorithm itself

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
The postprocessing step in particular is finishing with an `antsRegistration` step from the ANTs library@ants,
that allows for `1000x1000x1000` maximum steps.
This step could be the source of variation of the postprocessing in the previous study, as the number of iterations
required for convergence could vary depending on the input data. However, we could not observe this variability in our experiments.

Similarly, the preprocessing step involves a rigid registration that takes almost all the preprocessing time in our runs.
This step is performed using the `reg_aladin` tool from the NiftyReg library@niftyreg. This tool uses an iterative
approach to perform the registration, and the number of iterations required for convergence could vary depending on the input data.
Again, we could not observe this variability in our experiments.

= deepmriprep

Given the consistent performance of SLANT in our environment, we expanded our scope to `deepmriprep`@deepmriprep, another prominent neuroscience application.
As a deep learning-based MRI preprocessing pipeline, it offers a comparable workload structure but employs different underlying algorithms,
allowing us to verify if our observations were specific to SLANT or indicative of a broader trend in containerized neuroimaging tools.
The tool can perform multiple preprocessing steps, including:
- brain extraction
- affine registration
- tissue segmentation
- nonlinear registration
- smoothing

#figure(
  caption: [deepmriprep output example],
  image("images/deepmriprep_example.png")
)

#figure(
  caption: [deepmriprep atlas output example],
  image("images/deepmriprep_atlas_example.jpg"),
)

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
    [cpu],[128], [vbm], [75.8], [8.14],
    [cpu],[128], [rbm], [51.1], [1.0],
  )
) <tab:deepmriprep_walltime>

We observe in @tab:deepmriprep_walltime that the walltime is very consistent regardless of the number of threads used or the output type,
with a standard deviation being always below 2% of the mean time.
This shows that deepmriprep is also not affected by input variability when using the fMRI dataset from DRD, similarly to our study of SLANT.

This result is expected for the deep learning-based steps of deepmriprep, as they are deterministic for a given input.
However, some of the other steps, such as affine registration and smoothing, do not use deep learning models and could thus be affected by input variability.
The fact that we do not observe any significant variability in execution time suggests that these steps are also not significantly affected by input variability,
at least for the fMRI dataset used in this study.

= ANTS

Finally, we investigated the Advanced Normalization Tools (ANTs), a widely used open-source software suite for medical image processing and analysis@ants.
Unlike the containerized deep learning applications discussed previously, ANTs relies strictly on traditional iterative algorithms
for segmentation (specifically Expectation-Maximization).
In theory, this algorithmic approach introduces greater potential for runtime variability, as convergence depends heavily on the specific characteristics of the input data.
The suite includes:
- image registration
- segmentation
- template building
- brain extraction
- and a lot more

#figure(
  caption: [ANTS atropos output example],
  image("images/atropos_example.png"),
)

We focused our study on the brain segmentation functionality of ANTs, which can be used to segment brain MRI scans into different anatomical regions.
ANTs' Atropos algorithm performs segmentation using an iterative approach based on the Expectation-Maximization (EM) algorithm.
The algorithm iteratively refines the segmentation by updating the class probabilities and the model parameters until convergence.
We ran Atropos in CPU mode on our platform but, unlike SLANT and deepmriprep, we used a 3D T1-weighted MRI dataset from the OASIS-3 dataset@oasis3.
The full used dataset metadata can be found in our git repository associated with this study@this-git, and is composed of 2832 images of T1-weighted MRI
scans at variable sizes.

#figure(
  caption: [Atropos parameters],
  table(
    columns: 2,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[parameter][value],
    [smoothness],[0.3,1x1x1],
    [threshold],[1e-4],
    [max iterations],[50],
    [initialization],[kmeans(3)],
  )
) <tab:atropos_parameters>

We ran the Atropos algorithm using the parameters listed in @tab:atropos_parameters, which are commonly used for brain segmentation tasks.
The most important parameter here is the threshold value, which determines the convergence criteria of the algorithm.
The algorithm stops when the log-likelihood change between iterations is below this threshold.
This means that the condition, at step n, for stopping the algorithm is:
$
  |"likelihood"_n - "likelihood"_(n-1)| < "threshold"
$
It is this threshold value, in combination with the max iteration parameter, that can lead to variability in execution time,
as the number of iterations required for convergence can vary depending on the input data.
If the threshold is set too low, the algorithm may take a long time to converge, leading to maximum iteration being reached.
Conversely, if the threshold is set too high, the algorithm may converge instantly, leading to no variability in execution time.
We chose a threshold value of 1e-4, which is a common value used in practice, and a maximum of 50 iterations, which is a higher value than
the maximum number of iterations we observed in practice with our dataset.

#figure(
  caption: [Atropos histogram of number of iterations to convergence],
  image("images/.3_e4.png"),
) <fig:atropos_iterations_histogram>

From the histogram in @fig:atropos_iterations_histogram, we can see that the number of iterations required for convergence varies significantly depending on the input data,
with some images converging in one iterations, while others require more than 15 iterations to converge.
We can distinguish two distribution shapes in the histogram, with one distribution of images converging in one or two iterations,
and another in a normal distribution centered around 9 iterations.
To make sure that the variability observed is not purely random, we ran the algorithm multiple times on a subset of 10 images from the dataset
in @fig:atropos_iterations_multiple_runs, and observed that the number of iterations required for convergence is roughly the same
for each image across different runs, showing that the variability is indeed dependent on the input data.

#figure(
  caption: [Atropos number of iterations across 3 different runs],
  image("images/.3_e4_mul.png"),
) <fig:atropos_iterations_multiple_runs>

#figure(
  caption: [Atropos number of iterations vs file size],
  image("images/atropos_it_filesize.jpg"),
) <fig:atropos_iterations_filesize>

Finally, we plotted the number of iterations required for convergence against the image file size for 10 images of the dataset in @fig:atropos_iterations_filesize,
and observed no clear correlation. This suggests that the variability in execution time is not simply due to the size of the input data,
but rather to other characteristics of the images that affect the convergence of the algorithm.

== Deep learning prediction model

We decided to build a prediction model for the iteration count of the Atropos algorithm based on the input image.
The model pipeline is as follows:
1. Normalize the intensity of the input image using MONAI's@monai `ScaleIntensity` transform
2. Resize the input image to a fixed size of 64x64x64 voxels using MONAI's `Resize` transform
3. Feature extraction using a classic pattern of `Conv3d` → `BatchNorm` → `ReLU` → `MaxPool`. This 3D CNN pattern is repeated 4 times
4. Regression head consisting of `Flatten` → `Linear` → `ReLU` → `Dropout` → `Linear` to predict the number of iterations required for convergence

We trained the model on a subset of 2000 images and evaluated its performance on a separate test set of 500 images, both from the OASIS-3 dataset@oasis3.
Training this model took around 3 hours on our platform using the GPU and batch mode. We used the Mean Squared Error (MSE) as the loss function for training,
and the Mean Absolute Error (MAE) as an additional metric to evaluate the performance of the model.
The resulting model has 3,260,929 trainable parameters, with a resulting file size of around 13MB. This is a reasonable size for this task: on average,
the model can be loaded in memory in around 3.4s, and the inference time is around 300ms per image, which is negligible compared to the execution time
of the Atropos algorithm itself (around 26 seconds for 2-iteration images, and 140 seconds for 14-iteration images).

#figure(
  caption: [Atropos iteration count prediction model performance],
  table(
    columns: 2,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[metric][value],
    [Mean Squared Error (loss)],[2.49],
    [Mean Absolute Error],[1.14],
  )
) <tab:atropos_prediction_model_performance>

The model achieved a mean squared error of 2.49 and a mean absolute error of 1.14 on the test set as shown in @tab:atropos_prediction_model_performance.
This result is a good performance for this task: it shows that it is possible to predict with good precision the number of iterations required for convergence
of the Atropos algorithm based on the input image, which could be used to optimize the scheduling of jobs using this algorithm
by providing a more accurate walltime estimate.

After analyzing the results, we discovered that the Atropos algorithm convergence speed is highly correlated with the shape of the input image.
We don't know yet if this behaviour is strictly due to the shape of the image, or if it is also correlated with other characteristics of the image
that are themselves correlated with the shape. We ran our model on a separate test of 22 T1 images of shape (256x256x256) from the RDR datasets,
which is not a shape that was present in the OASIS3 training set. We observed a significant drop in performance,
with a mean absolute error of 2.88, which is more than double the MAE obtained on the OASIS3 test set, showing that the model is not able to generalize
well to images of a different shape, and that the shape of the image is indeed a very important factor for the convergence of the Atropos algorithm.

= Conclusion

In this study, we conducted a comprehensive performance analysis of several neuroscience applications, focusing on their execution time relative to input data.
We replicated the results of a previous study on the SLANT algorithm, and found that, contrary to their findings, the execution time of
SLANT is very consistent regardless of the input data.
This shows that variability, like the one observed in the previous study, can be caused by unidentified system variables, and that the study
of the variability of an algorithm can not be done by solely looking at the algorithm itself, but must also take into account other variables
such as the system on which it is running, its configuration, and more.
We also observed that this non-variability in execution time is not specific to SLANT, as we found the same behaviour in deepmriprep, another neuroscience application.
Finally, we investigated the ANTs Atropos algorithm, which uses an iterative approach for segmentation, and found that its execution
time varies significantly depending on the input data, with some images converging in one iteration, while others require more than 15 iterations to converge.
From these results, we derived a deep learning model to predict the number of iterations required for convergence of the Atropos algorithm based on the input image,
and achieved a good performance with a mean absolute error of 1.14 on the test set.
This model could be used to optimize the scheduling of jobs using the Atropos algorithm by providing a more accurate walltime estimate, especially if
these jobs are run a large number of times on an overloaded HPC cluster.
While running Atropos with our parameters already resulted in a relatively fast convergence of the images (taking up to 220 seconds for some images can be
considered reasonable), we hope that our machine-learning approach to predict the walltime of an algorithm based on its input data can be applied to other
algorithms with a more significant execution time, and thus lead to more efficient resource allocation and cost reduction in HPC environments.

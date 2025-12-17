#import "@preview/charged-ieee:0.1.4": ieee

#show: ieee.with(
  title: [Performance Analysis and Walltime Prediction for Neuroscience Applications],
  abstract: [
    With the recent upcomming of HPC, BigData and AI, the need for computational resources is ever increasing in the field of neuroscience.
    However, efficiently utilizing these resources remains a challenge due to the complexity of modern computing systems and the diverse nature of neuroscience applications.
    In this paper, we present a comprehensive performance analysis of several neuroscience applications, focusing on their execution time and memory footprint.
    In a second step, we will compare these results with other previous experiments done on some of these algorithms,
    then we will develop a model to predict the execution time and memory usage of these applications based on their input parameters and system configurations.
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

= Introduction

When designing an application, it is crucial to know whether it will run consistently depending on the input parameters.
This is especially true for stochastic applications, where the execution time can vary significantly based on the input.
Morehover, in the context of High-Performance Computing (HPC), where resources are often allocated based on estimated execution times,
having accurate predictions can lead to better resource management and cost savings. With the increasing complexity of neuroscience applications due to the rise of AI and Big Data,
it becomes even more important to understand and predict their performance characteristics.
In this paper, we focus on analyzing the performance of several neuroscience applications, with the goal of predicting their execution time and memory footprint based on input parameters.

= Study of Neuroscience Applications

In this section, we will study multiple neuroscience applications with different datasets and input parameters.
For each application, we will measure the execution time and memory footprint for various input configurations.

== Platform

All experiments were conducted on a machine with the following specifications:
- CPUs: 2 AMD EPYC 7502 32-Core Processor (64 threads \@ 2.50GHz)
- RAM: 504 GiB
When running the applications, we ensured that no other significant processes were running on the machine to avoid interference with the measurements.
Still, some background processes were taking on average 1% of CPU and 6% of RAM (i.e. around 30GiB of RAM).

== Dataset

We used the Dartmouth Raiders Dataset (DRD) for our experiments. We extracted two separate datasets from the DRD:
- A dataset containing 87 images of fMRI (Functional magnetic resonance imaging) scans. Each is a 4D scan, with 326 pictures at resolution of 80x80x41 voxels.
- A dataset containing 21 images of T1-weighted MRI (Magnetic resonance imaging) scans. Each is a 3D scan, with a resolution of 256x256x160 voxels.

== Spatially Localized Atlas Network Tiles (SLANT)

We study the SLANT algorithm, which is a deep learning-based method for whole brain segmentation.
Although SLANT is supposed to take 3D, T1-weighted MRI scans as input, we tested it with fMRI scans to compare with previous experiments done on SLANT which used the same fMRI dataset.
We studied both the CPU and GPU implementations of SLANT, taking into account both the execution time and memory footprint of SLANT with two different runtimes:
- Docker
- Singularity
Additionally, we varied the number of threads used for the CPU implementation with Singularity. We tested with:
- 1 thread
- all 128 threads
- 24 threads on one cpu socket, and 24 threads on the other cpu socket (48 threads in total)

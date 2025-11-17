#import "@preview/charged-ieee:0.1.4": ieee

#show: ieee.with(
  title: [Performance Analysis and Walltime Prediction for Neuroscience Applications],
  abstract: [
    With the recent upcomming of HPC, BigData and AI, the need for computational resources is ever increasing in the field of neuroscience.
    However, efficiently utilizing these resources remains a challenge due to the complexity of modern computing systems and the diverse nature of neuroscience applications.
    In this paper, we present a comprehensive performance analysis of several neuroscience applications, focusing on their execution time and memory footprint.
    In a second step, we will develop a model to predict the execution time and memory usage of these applications based on their input parameters and system configurations.
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

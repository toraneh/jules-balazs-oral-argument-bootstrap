---
title: "Simulating Variation in YouTube View Counts: A Civic-Data Simulation Using Sansad TV"
author: "Harsh Torane"
date: "9 August 2026"
header-includes: |
  \usepackage{graphicx}
  \usepackage{float}
---

## Abstract

Digital platforms give citizens growing access to parliamentary proceedings, along with publicly visible measures of audience attention. Sansad TV, India's parliamentary television channel, distributes its content through platforms including YouTube, opening a simple avenue for computational approaches to engagement data. This brief simulation study illustrates one such approach using a single observed YouTube view count.

The video *RS | Monsoon Session 2026 | Question Hour | Time: 12:00 PM–12:04 PM | 07 August, 2026* had **3,306 views** at the time of observation. Using R 4.5.0, 10,000 view counts were simulated from a Poisson distribution with an expected value of 3,306. The simulated mean was **3,304.6 views**, with an empirical 95% simulation interval of **3,192–3,416 views**. The exercise does not predict future views or claim that YouTube engagement follows a Poisson process. It instead shows how reproducible simulation can turn a single, publicly observable metric into an accessible example of statistical variation and civic-data literacy.

## Introduction

Public access to parliamentary information is a meaningful part of democratic participation. Sansad TV provides such access through television and digital platforms, including recordings of proceedings like Question Hour. Digital distribution also leaves behind engagement measures that anyone can observe, such as YouTube view counts.

A view count is not a direct measure of civic participation, political attitudes, or democratic impact. It can, however, serve as a concrete starting point for statistical exploration. Simulation offers one way to move past treating an observed count as a fixed number, by showing what variation around that observation might look like under an explicitly stated model.

This study presents a small proof of concept using one Sansad TV video. Its purpose is descriptive and methodological rather than predictive: to demonstrate a transparent, reproducible approach that could later be extended to larger collections of parliamentary videos and engagement data.

## Method

A Poisson model served as a simple exploratory baseline for simulating variation around the observed count of **3,306 views**. The Poisson distribution is a natural fit for integer-valued count data, though a single observation cannot establish that YouTube view counts actually follow this distribution.

Using **R 4.5.0** (base R only; no additional packages were required), random seed `123`, and an expected value of 3,306, **10,000 observations** were simulated. The mean, standard deviation, minimum, maximum, and empirical 95% simulation interval were then calculated, with the interval defined by the 2.5th and 97.5th percentiles.

## Results

The simulated mean was **3,304.6 views**, with a standard deviation of **57.0 views**. Values ranged from **3,086 to 3,527 views**, and the empirical 95% simulation interval was **3,192–3,416 views**. The simulated distribution was centered closely around the observed value of 3,306 views.

\begin{figure}[H]
\centering
\includegraphics[width=\textwidth]{Figure_1.png}
\caption{Distribution of 10,000 simulated YouTube view counts under the Poisson model. The red vertical line marks the observed count of 3,306 views, and the dashed gray line marks the simulated mean.}
\end{figure}

## Discussion and Conclusion

The simulation shows how a publicly visible digital engagement metric can anchor a reproducible statistical exercise. Rather than treating the observed count as an isolated number, simulation offers an accessible way to explore variation under an explicitly stated model.

This approach has some value for **civic-data literacy**. Parliamentary videos and their engagement metrics give citizens, students, educators, and researchers concrete material for exploring uncertainty, distributions, and reproducible quantitative reasoning. The present study should still be read as a proof of concept: it rests on one video and one observation, and the Poisson assumption is illustrative rather than empirically validated.

Future work could extend the framework to multiple Sansad TV videos and longitudinal observations, comparing engagement across sessions, topics, video characteristics, and time, and testing alternative models against the Poisson baseline.

## Reference

YouTube. (2026). *RS | Monsoon Session 2026 | Question Hour | Time: 12:00 PM -12:04 PM | 07 August, 2026* [Video]. YouTube. https://www.youtube.com/watch?v=mfZ5GKz2yjY

## Code Availability

The R code used to generate the simulation and Figure 1 is available in the accompanying [GitHub repository](https://github.com/toraneh/simulating-variation-in-youtube-view-count).

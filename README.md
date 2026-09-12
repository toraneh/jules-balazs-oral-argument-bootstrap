# Simulating Variation in YouTube View Counts: A Civic-Data Simulation Using Sansad TV

A small, reproducible simulation study exploring variation around an observed YouTube view count from Sansad TV. The project uses a Poisson model as an exploratory baseline and demonstrates how publicly observable digital engagement metrics can be used for statistical exploration and civic-data literacy.

## Overview

This project examines variation around an observed YouTube view count of **3,306 views** for the video:

*RS | Monsoon Session 2026 | Question Hour | Time: 12:00 PM -12:04 PM | 07 August, 2026*

Sansad TV provides public access to parliamentary proceedings and related programming through digital platforms, including YouTube. Publicly visible engagement metrics such as view counts provide a simple starting point for computational exploration.

The simulation is intended as a **descriptive proof-of-concept**, not as a prediction of future views or a measure of civic participation.

## Simulation

The simulation was conducted in **R 4.5.0** using:

* **10,000** simulated observations
* Poisson mean (`lambda`) = **3,306**
* Random seed = **123**

The simulation calculates the mean, standard deviation, minimum, maximum, and empirical 95% simulation interval.

## Results

The simulation produced:

| Statistic              |      Result |
| ---------------------- | ----------: |
| Observed views         |       3,306 |
| Simulated mean         |   3,304.636 |
| Standard deviation     |      57.003 |
| Minimum                |       3,086 |
| Maximum                |       3,527 |
| Empirical 95% interval | 3,192–3,416 |

The results are descriptive. They should not be interpreted as evidence that YouTube view counts generally follow a Poisson distribution.

## Civic-Data Context

The project explores a simple connection between **parliamentary media, publicly observable digital engagement, and reproducible statistical reasoning**.

The simulation demonstrates how an observed public metric can be transformed into an accessible statistical exercise. This approach may have applications in civic-data literacy, allowing citizens, students, educators, and researchers to explore concepts such as distributions, variation, uncertainty, and reproducibility using real-world public data.

The present study uses only one video and one observation. It therefore does not establish general patterns of audience engagement with Sansad TV or parliamentary content. Future research could extend the framework to multiple videos, longitudinal observations, different parliamentary sessions, and alternative statistical models.

## Repository Contents

* `paper.pdf` — PDF version of the paper
* `paper.md` — Markdown source
* `analysis.R` — R code used for the simulation and Figure 1
* `figure_1_view_count_distribution.png` — Figure 1

## Reproducibility

To reproduce the simulation, open `analysis.R` in **R 4.5.0** or a compatible version of R and run the script.

The simulation uses random seed `123` to ensure reproducibility.

## Data Source

The observed count comes from the following YouTube video:

*RS | Monsoon Session 2026 | Question Hour | Time: 12:00 PM -12:04 PM | 07 August, 2026*

YouTube (2026).

## Citation

If you use this work or data in your research, please cite it as:

> Torane, H. “Simulating Variation in YouTube View Counts: A Civic-Data Simulation Using Sansad TV”. Preprint, Zenodo, September 11, 2026. https://doi.org/10.5281/zenodo.22234219

## License

Unless otherwise specified, the accompanying code and materials are provided for research and educational use.

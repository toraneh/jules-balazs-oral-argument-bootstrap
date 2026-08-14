# Jules v. Andre Balazs Properties: Transcript Bootstrap Analysis

Reproducible R analysis of the oral argument transcript in **Jules v. Andre Balazs Properties, No. 25-83**, before the Supreme Court of the United States.

The project extracts speaking turns from the official transcript and performs exactly **10,000 bootstrap resamples** of those turns.

## Case and Source

**Jules v. Andre Balazs Properties, et al.**
Supreme Court of the United States, No. 25-83
Argued March 30, 2026

Official sources:

* [U.S. Supreme Court — Docket No. 25-83](https://www.supremecourt.gov/docket/docketfiles/html/public/25-83.html)
* [U.S. Supreme Court — Oral Argument](https://www.supremecourt.gov/oral_arguments/audio/2025/25-83)
* [U.S. Supreme Court — Oral Argument Transcripts](https://www.supremecourt.gov/oral_arguments/argument_transcript/2025)
* [U.S. Supreme Court — Opinion](https://www.supremecourt.gov/opinions/25pdf/25-83_3e04.pdf)

## Analysis

The transcript is cleaned and divided into individual speaking turns. The analysis measures:

1. Mean words per speaking turn
2. Percentage of speaking turns containing a question mark

Each bootstrap simulation samples **225 speaking turns with replacement** and recalculates both measures.

The analysis therefore estimates the variability of statistics from the observed transcript; it does **not** generate 10,000 hypothetical oral arguments.

## Results

The cleaned transcript contained:

* **225** speaking turns
* **11** identified speakers
* **0** remaining transcript artifacts

| Measure                   | Observed | Bootstrap Mean |    SD | 95% Interval |
| ------------------------- | -------: | -------------: | ----: | -----------: |
| Mean words per turn       |    82.54 |          81.69 | 33.96 | 40.19–157.22 |
| Question-containing turns |   32.00% |         31.91% |  3.07 | 25.78–38.22% |

The analysis uses `set.seed(20260808)` and exactly **10,000** bootstrap simulations.

## Reproduction

Requirements:

* R 4.5.0
* `pdftools`
* `stringr`
* `dplyr`
* `ggplot2`
* `readr`

Repository structure:

```text
jules-scotus-transcript-bootstrap/
├── data/
│   └── transcript.pdf
├── output/
├── analysis.R
└── README.md
```

Run:

```r
source("analysis.R")
```

The script produces:

```text
output/
├── extracted_speaking_turns.csv
├── 10000_simulation_results.csv
├── simulation_summary.csv
└── Figure_1_bootstrap_speaking_turn_length.png
```

## Limitation

This is a case-specific transcript analysis and should not be interpreted as representative of Supreme Court oral arguments generally. "Question" is defined simply as a speaking turn containing `?`.

## Repository

[GitHub repository](YOUR-GITHUB-REPOSITORY-URL)

## Citation

If you use this work or data in your research, please cite it as:

> Torane, H. (2026). *Bootstrap Analysis of Speaking Turns in Jules v. Andre Balazs Properties* [Unpublished manuscript].

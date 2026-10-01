# Bootstrap Analysis of Speaking Turns in Jules v. Andre Balazs Properties

This repository contains a fully reproducible R implementation of bootstrap resampling analysis applied to the oral argument transcript in *Jules v. Andre Balazs Properties*, No. 25-83 (U.S. Supreme Court).

## Case information and sources

**Jules v. Andre Balazs Properties, et al.**
- **Citation:** No. 25-83, U.S. Supreme Court
- **Argument date:** March 30, 2026

Official sources:
- [Supreme Court docket No. 25-83](https://www.supremecourt.gov/docket/docketfiles/html/public/25-83.html)
- [Oral argument audio](https://www.supremecourt.gov/oral_arguments/audio/2025/25-83)
- [Oral argument transcript](https://www.supremecourt.gov/oral_arguments/argument_transcript/2025)
- [Opinion](https://www.supremecourt.gov/opinions/25pdf/25-83_3e04.pdf)

## Methodology

The official Supreme Court oral-argument transcript was cleaned to extract individual speaking turns. Bootstrap resampling estimates the sampling distribution of two measures:

1. **Mean words per speaking turn:** average length of spoken contributions.
2. **Percentage of question-containing turns:** frequency of interrogative speech in oral argument.

Each of 10,000 bootstrap samples resamples 225 speaking turns with replacement and recalculates both measures. This approach provides confidence intervals and standard errors reflecting the uncertainty inherent in sampling from a finite population.

## Results

The cleaned transcript comprises 225 speaking turns from 11 identified speakers, with 0 remaining transcript artifacts.

| Measure | Observed value | Bootstrap mean | SD | 95% CI |
|:--------|--------------:|---------------:|----:|:--------|
| Mean words per turn | 82.54 | 81.69 | 33.96 | 40.19–157.22 |
| Question-containing turns (%) | 32.00% | 31.91% | 3.07 | 25.78–38.22% |

Analysis uses `set.seed(20260808)` for reproducibility across exactly 10,000 bootstrap iterations.

## Computational requirements and reproduction

**R version and dependencies:**
- R ≥ 4.5.0
- pdftools
- stringr
- dplyr
- ggplot2
- readr

**Repository structure:**
```text
jules-balazs-oral-argument-bootstrap/
├── data/
│   └── transcript.pdf
├── output/
├── analysis.R
└── README.md
```

**To reproduce:**
Execute the analysis with:
```r
source("analysis.R")
```

**Output files:**
The script generates the following outputs in the `output/` directory:
- `extracted_speaking_turns.csv` — cleaned speaking-turn data
- `10000_simulation_results.csv` — full bootstrap simulation results
- `simulation_summary.csv` — summary statistics across bootstrap samples
- `Figure_1.png` — visualization of bootstrap distributions

## Scope and limitations

This analysis is specific to a single Supreme Court oral argument and should not be generalized to the broader population of oral arguments. A "question" is operationalized as any speaking turn containing a question mark.

## Citation

If you use this analysis, code, or derived data, please cite it as:

> Torane, H. (2026). Bootstrap Analysis of Speaking Turns in Jules v. Andre Balazs Properties. *Preprint*. Law Archive. https://doi.org/10.31219/osf.io/5akpj_v6

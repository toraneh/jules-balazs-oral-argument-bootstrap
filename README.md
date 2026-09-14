# Bootstrap Analysis of Speaking Turns in Jules v. Andre Balazs Properties

This repository contains a fully reproducible R implementation of bootstrap resampling analysis applied to the oral argument transcript in *Jules v. Andre Balazs Properties*, No. 25-83 (U.S. Supreme Court). The analysis extracts speaking turns from the official transcript and performs 10,000 bootstrap simulations to estimate the sampling variability of two key measures.

## Case Information and Sources

**Jules v. Andre Balazs Properties, et al.**
- **Citation:** No. 25-83, U.S. Supreme Court
- **Argument Date:** March 30, 2026

Official sources:
- [Supreme Court Docket No. 25-83](https://www.supremecourt.gov/docket/docketfiles/html/public/25-83.html)
- [Oral Argument Audio](https://www.supremecourt.gov/oral_arguments/audio/2025/25-83)
- [Oral Argument Transcripts](https://www.supremecourt.gov/oral_arguments/argument_transcript/2025)
- [Opinion](https://www.supremecourt.gov/opinions/25pdf/25-83_3e04.pdf)

## Methodology

The official Supreme Court oral argument transcript was cleaned to extract individual speaking turns. Bootstrap resampling estimates the sampling distribution of two measures:

1. **Mean words per speaking turn:** Average length of spoken contributions.
2. **Percentage of question-containing turns:** Frequency of interrogative speech in oral argument.

Each of 10,000 bootstrap samples resamples 225 speaking turns with replacement and recalculates both measures. This approach provides confidence intervals and standard errors reflecting the uncertainty inherent in the observed transcript data. The analysis does not generate hypothetical arguments; it characterizes the observed data's variability.

## Results

The cleaned transcript comprises 225 speaking turns from 11 identified speakers with 0 remaining transcript artifacts.

| Measure                           | Observed Value | Bootstrap Mean |    SD | 95% CI       |
|:----------------------------------|--------------:|---------------:|------:|:-------------|
| Mean words per turn               | 82.54         | 81.69          | 33.96 | 40.19–157.22 |
| Question-containing turns (%)     | 32.00%        | 31.91%         |  3.07 | 25.78–38.22% |

Analysis uses `set.seed(20260808)` for reproducibility across exactly 10,000 bootstrap iterations.

## Computational Requirements and Reproduction

**R Version and Dependencies:**
- R ≥ 4.5.0
- pdftools
- stringr
- dplyr
- ggplot2
- readr

**Repository Structure:**
```text
jules-balazs-oral-argument-bootstrap/
├── data/
│   └── transcript.pdf
├── output/
├── analysis.R
└── README.md
```

**To Reproduce:**
Execute the analysis with:
```r
source("analysis.R")
```

**Output Files:**
The script generates the following outputs in the `output/` directory:
- `extracted_speaking_turns.csv` — Cleaned speaking turn data
- `10000_simulation_results.csv` — Full bootstrap simulation results
- `simulation_summary.csv` — Summary statistics across bootstrap samples
- `Figure_1.png` — Visualization of bootstrap distributions

## Scope and Limitations

This analysis is specific to a single Supreme Court oral argument and should not be generalized to the broader population of oral arguments. A "question" is operationalized as any speaking turn containing a question mark character (?). This simple lexical definition may misclassify some utterances (e.g., rhetorical questions, questions embedded in other speech forms). Researchers are encouraged to adapt the definition for alternative analytical purposes in future research.

## Citation

If you use this analysis, code, or derived data, please cite it as:

> > Torane, H. (2026). Bootstrap Analysis of Speaking Turns in Jules v. Andre Balazs Properties [Preprint]. Law Archive. https://doi.org/10.31219/osf.io/5akpj_v1

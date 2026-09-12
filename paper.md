---
title: "Bootstrap Analysis of Speaking Turns in *Jules v. Andre Balazs Properties*"
author: "Harsh Torane"
date: "9 August 2026"
---

## Abstract

This study examines the oral argument transcript in *Jules v. Andre Balazs Properties*, No. 25-83, before the Supreme Court of the United States. The transcript was programmatically cleaned and divided into 225 speaking turns involving 11 identified speakers. Two transcript-level measures were examined: mean words per speaking turn and the percentage of turns containing a question.

A nonparametric bootstrap procedure generated 10,000 resamples of the 225 observed speaking turns. The observed mean speaking-turn length was 82.54 words, and 32.00% of turns contained a question. Across the bootstrap resamples, the mean estimated speaking-turn length was 81.69 words (standard deviation [SD] = 33.96; 95% percentile interval = 40.19–157.22), and the mean estimated percentage of question-containing turns was 31.91% (SD = 3.07; 95% percentile interval = 25.78–38.22%).

The results show these two simple transcript-level measures to be reproducible, though they differ notably in sampling variability.

## 1. Introduction

Oral arguments before the Supreme Court unfold as a sequence of exchanges between Justices and attorneys. Basic properties of these exchanges — such as speaking-turn length and how often a turn contains a question — can be measured directly from the official transcript.

This study offers a small, reproducible analysis of the oral argument in *Jules v. Andre Balazs Properties*. Its purpose is not to predict judicial outcomes or model hypothetical arguments, but to ask a narrower question: how stable are these two transcript-level statistics under repeated resampling of the observed speaking turns?

## 2. Data and Method

### 2.1 Source and Transcript Processing

The analysis draws on the official Supreme Court oral-argument transcript for *Jules v. Andre Balazs Properties*, No. 25-83, argued March 30, 2026.

The transcript was processed in R using the following packages:

- `pdftools`
- `stringr`
- `dplyr`
- `ggplot2`
- `readr`

The extraction procedure identified the Justices and attorneys, reconstructed multi-line speaking turns, and removed common PDF and transcript artifacts. The resulting dataset contained 225 speaking turns across 11 speakers, with no remaining artifacts.

### 2.2 Measures

Two measures were calculated for each speaking turn:

- Number of words in the turn.
- Whether the turn contained a question mark (`?`).

### 2.3 Bootstrap Procedure

The observed transcript was bootstrapped 10,000 times, each resample consisting of 225 speaking turns drawn with replacement from the observed 225. Both statistics were recalculated for every resample.

`set.seed(20260808)` was used throughout to make the bootstrap reproducible.

## 3. Results

The observed transcript contained 225 speaking turns. Mean speaking-turn length was 82.54 words, with a median of 22 words; 72 turns (32.00%) contained a question mark.

The bootstrap results were:

| Measure | Observed | Bootstrap Mean | SD | 95% Percentile Interval |
|:--|--:|--:|--:|--:|
| Mean words per speaking turn | 82.54 | 81.69 | 33.96 | 40.19–157.22 |
| Question-containing turns (%) | 32.00% | 31.91% | 3.07 | 25.78–38.22% |

![Bootstrap distribution of mean speaking-turn length across 10,000 resamples of the 225 observed speaking turns.](Figure_1.png)

Both bootstrap means landed close to their observed counterparts, but the distribution of mean speaking-turn length was considerably wider than that of the question-containing rate — a reflection of how much individual turn lengths vary.

## 4. Discussion

The two transcript measures are reproduced closely on average under resampling, and the observed question-containing rate of 32.00% sits particularly close to the bootstrap mean of 31.91%.

Speaking-turn length is far more variable. Although the observed mean was 82.54 words, the bootstrap distribution was wide, reflecting a mix of short and very long turns; the median of 22 words further highlights the skew created by the longer ones.

These results should be read narrowly. The bootstrap does not generate 10,000 hypothetical oral arguments — it resamples the 225 observed turns to characterize the sampling variability of the calculated statistics. The analysis therefore describes uncertainty in these transcript-level measures rather than making broader claims about Supreme Court arguments generally.

## 5. Conclusion

This reproducible bootstrap analysis of the *Jules v. Andre Balazs Properties* oral argument found a stable question-frequency estimate alongside much greater variability in speaking-turn length. The exercise demonstrates how publicly available Supreme Court transcripts can be converted into structured data and examined with a straightforward statistical procedure.

## 6. Data and Reproducibility

All analysis code and generated results are available in the accompanying [GitHub repository](https://github.com/toraneh/jules-balazs-oral-argument-bootstrap).

The official case materials, including the docket and oral-argument transcript, are available from the Supreme Court of the United States.

The analysis was run using:

- **R:** 4.5.0
- **Poppler:** 25.03.0
- **Bootstrap resamples:** 10,000
- **Random seed:** `20260808`
- **Observed speaking turns:** 225
- **Identified speakers:** 11

The reported results are based on the processed transcript and the bootstrap procedure described above.

############################################################
# CLEAN SUPREME COURT TRANSCRIPT EXTRACTION
# AND PUBLICATION-SAFE BOOTSTRAP FIGURE
############################################################
#
# Published values preserved:
#   Speaking turns:               225
#   Identified speakers:           11
#   Observed mean:                82.54
#   Observed median:              22
#   Question-containing turns:    72
#   Question percentage:          32.00%
#   Bootstrap simulations:        10,000
#   Bootstrap mean:               81.69
#   Bootstrap SD:                 33.96
#   Bootstrap 95% interval:       40.19–157.22
#   Random seed:                  20260808
############################################################


############################################################
# 1. PACKAGES
############################################################

library(pdftools)
library(stringr)
library(dplyr)
library(ggplot2)
library(readr)


############################################################
# 2. SELECT OFFICIAL TRANSCRIPT PDF
############################################################

pdf_file <- "data/transcript.pdf"


############################################################
# 3. EXTRACT PDF TEXT
############################################################

transcript <- pdf_text(pdf_file)

full_text <- paste(
  transcript,
  collapse = "\n"
)

lines <- unlist(
  strsplit(
    full_text,
    "\n"
  )
)

lines <- str_trim(lines)


############################################################
# 4. ACTUAL SPEAKER PATTERN
############################################################

speaker_pattern <- paste0(
  "^[0-9]+[[:space:]]+(",
  "CHIEF JUSTICE ROBERTS|",
  "JUSTICE ALITO|",
  "JUSTICE BARRETT|",
  "JUSTICE GORSUCH|",
  "JUSTICE JACKSON|",
  "JUSTICE KAGAN|",
  "JUSTICE KAVANAUGH|",
  "JUSTICE SOTOMAYOR|",
  "JUSTICE THOMAS|",
  "MR\\. UNIKOWSKY|",
  "MR\\. GEYSER",
  "):[[:space:]]*(.*)$"
)


############################################################
# 5. RECONSTRUCT ACTUAL SPEAKING TURNS
############################################################

utterances <- data.frame(
  speaker = character(),
  text = character(),
  stringsAsFactors = FALSE
)

current_speaker <- NULL
current_text <- NULL
started <- FALSE

for (line in lines) {

  match <- str_match(
    line,
    speaker_pattern
  )

  if (!is.na(match[1, 1])) {

    started <- TRUE

    ########################################################
    # SAVE PREVIOUS TURN
    ########################################################

    if (
      !is.null(current_speaker) &&
        !is.null(current_text) &&
        nchar(str_trim(current_text)) > 0
    ) {

      utterances <- rbind(
        utterances,
        data.frame(
          speaker = current_speaker,
          text = str_trim(current_text),
          stringsAsFactors = FALSE
        )
      )
    }

    ########################################################
    # START NEW TURN
    ########################################################

    current_speaker <- str_trim(
      match[1, 2]
    )

    current_text <- match[1, 3]

  } else if (
    started &&
      !is.null(current_speaker)
  ) {

    ########################################################
    # REMOVE HERITAGE FOOTER
    ########################################################

    if (
      str_detect(
        line,
        "^Heritage Reporting Corporation"
      )
    ) {
      next
    }

    ########################################################
    # REMOVE TRANSCRIPT HEADER
    ########################################################

    if (
      str_detect(
        line,
        "^Official - Subject to Final Review"
      )
    ) {
      next
    }

    ########################################################
    # REMOVE PAGE / LINE NUMBERS
    ########################################################

    cleaned_line <- sub(
      "^[[:space:]]*[0-9]+[[:space:]]+",
      "",
      line
    )

    cleaned_line <- str_trim(
      cleaned_line
    )

    ########################################################
    # IGNORE EMPTY LINES
    ########################################################

    if (
      nchar(cleaned_line) == 0
    ) {
      next
    }

    ########################################################
    # IGNORE LINES CONSISTING ONLY OF NUMBERS
    ########################################################

    if (
      str_detect(
        cleaned_line,
        "^[0-9]+$"
      )
    ) {
      next
    }

    ########################################################
    # ADD CONTINUATION TEXT
    ########################################################

    current_text <- paste(
      current_text,
      cleaned_line
    )
  }
}


############################################################
# 6. SAVE FINAL SPEAKING TURN
############################################################

if (
  !is.null(current_speaker) &&
    !is.null(current_text) &&
    nchar(str_trim(current_text)) > 0
) {

  utterances <- rbind(
    utterances,
    data.frame(
      speaker = current_speaker,
      text = str_trim(current_text),
      stringsAsFactors = FALSE
    )
  )
}


############################################################
# 7. REMOVE NON-SPOKEN TRANSCRIPT LABELS
############################################################

utterances <- utterances |>
  mutate(
    text = str_remove_all(
      text,
      "\\s+ORAL ARGUMENT OF.*$"
    ),
    text = str_remove_all(
      text,
      "\\s+REBUTTAL ARGUMENT OF.*$"
    ),
    text = str_trim(text)
  )


############################################################
# 8. REMOVE VERY SHORT ENTRIES
############################################################

utterances <- utterances |>
  filter(
    nchar(text) >= 5
  )


############################################################
# 9. CALCULATE WORD COUNTS AND QUESTION INDICATOR
############################################################

utterances <- utterances |>
  mutate(
    words = str_count(
      text,
      "\\S+"
    ),
    contains_question = str_detect(
      text,
      fixed("?")
    )
  )


############################################################
# 10. CHECK FOR TRANSCRIPT ARTIFACTS
############################################################

artifact_check <- utterances |>
  filter(
    str_detect(
      text,
      paste0(
        "Heritage Reporting|Official - Subject|",
        "ORAL ARGUMENT OF|REBUTTAL ARGUMENT OF"
      )
    )
  )


############################################################
# 11. OBSERVED STATISTICS
############################################################

observed_n_turns <- nrow(
  utterances
)

observed_n_speakers <- length(
  unique(
    utterances$speaker
  )
)

observed_mean_words <- mean(
  utterances$words
)

observed_median_words <- median(
  utterances$words
)

observed_question_count <- sum(
  utterances$contains_question
)

observed_question_percent <-
  mean(
    utterances$contains_question
  ) * 100


############################################################
# 12. HARD CHECKS AGAINST PUBLISHED PREPRINT
############################################################

if (
  observed_n_turns != 225
) {
  stop(
    paste0(
      "STOP: Expected 225 speaking turns, but extracted ",
      observed_n_turns,
      "."
    )
  )
}

if (
  observed_n_speakers != 11
) {
  stop(
    paste0(
      "STOP: Expected 11 speakers, but identified ",
      observed_n_speakers,
      "."
    )
  )
}

if (
  round(observed_mean_words, 2) != 82.54
) {
  stop(
    paste0(
      "STOP: Published observed mean is 82.54, but current ",
      "extraction gives ",
      round(observed_mean_words, 2),
      "."
    )
  )
}

if (
  round(observed_median_words, 2) != 22
) {
  stop(
    paste0(
      "STOP: Published median is 22, but current extraction ",
      "gives ",
      round(observed_median_words, 2),
      "."
    )
  )
}

if (
  observed_question_count != 72
) {
  stop(
    paste0(
      "STOP: Published question-containing turn count is 72, ",
      "but current extraction gives ",
      observed_question_count,
      "."
    )
  )
}

if (
  round(observed_question_percent, 2) != 32.00
) {
  stop(
    paste0(
      "STOP: Published question percentage is 32.00%, ",
      "but current extraction gives ",
      round(observed_question_percent, 2),
      "%."
    )
  )
}

if (
  nrow(artifact_check) != 0
) {
  stop(
    "STOP: Transcript artifacts remain in extracted speaking turns."
  )
}


############################################################
# 13. EXACTLY 10,000 NONPARAMETRIC BOOTSTRAP SIMULATIONS
############################################################

n_simulations <- 10000

set.seed(
  20260808
)

simulation_results <- data.frame(
  simulation = seq_len(n_simulations),
  mean_words = numeric(n_simulations),
  question_percent = numeric(n_simulations)
)


############################################################
# 14. RUN BOOTSTRAP
############################################################

for (i in seq_len(n_simulations)) {

  simulated_turns <- sample(
    seq_len(nrow(utterances)),
    size = nrow(utterances),
    replace = TRUE
  )

  simulation_results$mean_words[i] <-
    mean(
      utterances$words[
        simulated_turns
      ]
    )

  simulation_results$question_percent[i] <-
    mean(
      utterances$contains_question[
        simulated_turns
      ]
    ) * 100
}


############################################################
# 15. VERIFY EXACTLY 10,000 SIMULATIONS
############################################################

if (
  nrow(simulation_results) != n_simulations
) {
  stop(
    "STOP: Number of bootstrap simulations is not exactly 10,000."
  )
}


############################################################
# 16. BOOTSTRAP SUMMARY STATISTICS
############################################################

mean_words_lower <- unname(
  quantile(
    simulation_results$mean_words,
    0.025
  )
)

mean_words_upper <- unname(
  quantile(
    simulation_results$mean_words,
    0.975
  )
)

question_lower <- unname(
  quantile(
    simulation_results$question_percent,
    0.025
  )
)

question_upper <- unname(
  quantile(
    simulation_results$question_percent,
    0.975
  )
)

simulation_mean_words <- mean(
  simulation_results$mean_words
)

simulation_sd_words <- sd(
  simulation_results$mean_words
)

simulation_mean_questions <- mean(
  simulation_results$question_percent
)

simulation_sd_questions <- sd(
  simulation_results$question_percent
)


############################################################
# 17. HARD CHECKS AGAINST PUBLISHED BOOTSTRAP RESULTS
############################################################

tol <- 0.01

if (
  abs(simulation_mean_words - 81.69) > tol
) {
  stop(
    paste0(
      "STOP: Published bootstrap mean is 81.69, but current ",
      "result is ",
      round(simulation_mean_words, 2),
      "."
    )
  )
}

if (
  abs(simulation_sd_words - 33.96) > tol
) {
  stop(
    paste0(
      "STOP: Published bootstrap SD is 33.96, but current ",
      "result is ",
      round(simulation_sd_words, 2),
      "."
    )
  )
}

if (
  abs(mean_words_lower - 40.19) > tol
) {
  stop(
    paste0(
      "STOP: Published lower 95% limit is 40.19, but current ",
      "result is ",
      round(mean_words_lower, 2),
      "."
    )
  )
}

if (
  abs(mean_words_upper - 157.22) > tol
) {
  stop(
    paste0(
      "STOP: Published upper 95% limit is 157.22, but current ",
      "result is ",
      round(mean_words_upper, 2),
      "."
    )
  )
}

if (
  abs(simulation_mean_questions - 31.91) > tol
) {
  stop(
    paste0(
      "STOP: Published bootstrap question mean is 31.91%, ",
      "but current result is ",
      round(simulation_mean_questions, 2),
      "%."
    )
  )
}

if (
  abs(simulation_sd_questions - 3.07) > tol
) {
  stop(
    paste0(
      "STOP: Published bootstrap question SD is 3.07%, ",
      "but current result is ",
      round(simulation_sd_questions, 2),
      "%."
    )
  )
}

if (
  abs(question_lower - 25.78) > tol
) {
  stop(
    paste0(
      "STOP: Published lower question interval is 25.78%, ",
      "but current result is ",
      round(question_lower, 2),
      "%."
    )
  )
}

if (
  abs(question_upper - 38.22) > tol
) {
  stop(
    paste0(
      "STOP: Published upper question interval is 38.22%, ",
      "but current result is ",
      round(question_upper, 2),
      "%."
    )
  )
}


############################################################
# 18. PRINT VERIFIED RESULTS
############################################################

cat("\n")
cat("============================================\n")
cat("PUBLISHED RESULTS VERIFIED\n")
cat("============================================\n\n")

cat(
  "Speaking turns: ",
  observed_n_turns,
  "\n",
  sep = ""
)

cat(
  "Speakers: ",
  observed_n_speakers,
  "\n",
  sep = ""
)

cat(
  "Observed mean: ",
  round(observed_mean_words, 2),
  "\n",
  sep = ""
)

cat(
  "Observed median: ",
  round(observed_median_words, 2),
  "\n",
  sep = ""
)

cat(
  "Question-containing turns: ",
  observed_question_count,
  " (",
  sprintf("%.2f", observed_question_percent),
  "%)\n",
  sep = ""
)

cat(
  "Bootstrap simulations: ",
  nrow(simulation_results),
  "\n",
  sep = ""
)

cat(
  "Bootstrap mean: ",
  round(simulation_mean_words, 2),
  "\n",
  sep = ""
)

cat(
  "Bootstrap SD: ",
  round(simulation_sd_words, 2),
  "\n",
  sep = ""
)

cat(
  "Bootstrap 95% interval: ",
  round(mean_words_lower, 2),
  "–",
  round(mean_words_upper, 2),
  "\n",
  sep = ""
)


############################################################
# 19. CREATE OUTPUT DIRECTORY
############################################################

if (
  !dir.exists("output")
) {
  dir.create(
    "output",
    recursive = TRUE
  )
}

output_folder <- "output"


############################################################
# 20. PUBLICATION-QUALITY FIGURE
#
# The figure is saved ONLY as PNG.
#
# paper.md embeds:
#
# Figure_1_bootstrap_speaking_turn_length.png
#
############################################################

plot1 <- ggplot(
  simulation_results,
  aes(
    x = mean_words
  )
) +

  geom_histogram(
    binwidth = 5,
    boundary = 0,
    closed = "left",
    fill = "grey45",
    colour = "grey20",
    linewidth = 0.2
  ) +

  ##########################################################
  # 95% PERCENTILE BOOTSTRAP INTERVAL
  ##########################################################

  geom_vline(
    xintercept = mean_words_lower,
    linetype = "dashed",
    linewidth = 0.7,
    colour = "grey25"
  ) +

  geom_vline(
    xintercept = mean_words_upper,
    linetype = "dashed",
    linewidth = 0.7,
    colour = "grey25"
  ) +

  ##########################################################
  # OBSERVED TRANSCRIPT MEAN
  ##########################################################

  geom_vline(
    xintercept = observed_mean_words,
    linetype = "solid",
    linewidth = 1.0,
    colour = "black"
  ) +

  ##########################################################
  # LABELS
  ##########################################################

  labs(
    title = "Bootstrap Distribution of Mean Speaking-Turn Length",
    subtitle = "10,000 resamples of 225 observed speaking turns",
    x = "Mean words per speaking turn",
    y = "Bootstrap resamples per bin"
  ) +

  ##########################################################
  # X AXIS
  ##########################################################

  scale_x_continuous(
    breaks = seq(
      0,
      ceiling(
        max(simulation_results$mean_words) / 25
      ) * 25,
      by = 25
    ),
    expand = expansion(
      mult = c(0.01, 0.02)
    )
  ) +

  ##########################################################
  # Y AXIS
  #
  # 10,000 is the TOTAL number of bootstrap resamples.
  # The y-axis counts resamples within individual bins.
  ##########################################################

  scale_y_continuous(
    breaks = seq(
      0,
      1500,
      by = 500
    ),
    limits = c(
      0,
      1500
    ),
    expand = expansion(
      mult = c(0, 0.02)
    )
  ) +

  ##########################################################
  # Author prefers this theme
  ##########################################################

  theme_classic(
    base_size = 12
  ) +

  theme(
    plot.title = element_text(
      size = 15,
      face = "bold",
      margin = margin(
        b = 4
      )
    ),

    plot.subtitle = element_text(
      size = 10.5,
      margin = margin(
        b = 10
      )
    ),

    axis.title = element_text(
      size = 11
    ),

    axis.text = element_text(
      size = 9.5
    ),

    axis.line = element_line(
      linewidth = 0.5
    ),

    axis.ticks = element_line(
      linewidth = 0.5
    ),

    panel.grid = element_blank(),

    plot.margin = margin(
      10,
      12,
      10,
      10
    )
  )


############################################################
# 21. DISPLAY FIGURE
############################################################

print(
  plot1
)


############################################################
# 22. SAVE ONLY THE PNG FIGURE
#
# This is the ONLY standalone figure image generated.
############################################################

figure_png <- file.path(
  output_folder,
  "Figure_1_bootstrap_speaking_turn_length.png"
)

ggsave(
  filename = figure_png,
  plot = plot1,
  width = 7.5,
  height = 5.5,
  units = "in",
  dpi = 600
)


############################################################
# 23. SAVE BOOTSTRAP RESULTS
############################################################

write_csv(
  simulation_results,
  file.path(
    output_folder,
    "10000_simulation_results.csv"
  )
)


############################################################
# 24. SAVE EXTRACTED SPEAKING TURNS
############################################################

write_csv(
  utterances,
  file.path(
    output_folder,
    "extracted_speaking_turns.csv"
  )
)


############################################################
# 25. SAVE SUMMARY STATISTICS
############################################################

results_summary <- data.frame(
  measure = c(
    "Mean words per speaking turn",
    "Question-containing turns (%)"
  ),
  observed = c(
    observed_mean_words,
    observed_question_percent
  ),
  bootstrap_mean = c(
    simulation_mean_words,
    simulation_mean_questions
  ),
  bootstrap_sd = c(
    simulation_sd_words,
    simulation_sd_questions
  ),
  lower_95 = c(
    mean_words_lower,
    question_lower
  ),
  upper_95 = c(
    mean_words_upper,
    question_upper
  )
)

write_csv(
  results_summary,
  file.path(
    output_folder,
    "simulation_summary.csv"
  )
)


############################################################
# 26. SAVE FIGURE CAPTION
############################################################

figure_caption <- paste0(
  "Figure 1. Bootstrap distribution of mean speaking-turn ",
  "length across 10,000 resamples of the 225 observed ",
  "speaking turns. Each bootstrap resample contains 225 ",
  "speaking turns sampled with replacement. The solid ",
  "vertical line indicates the observed transcript mean ",
  "(82.54 words per turn). Dashed vertical lines indicate ",
  "the 95% bootstrap interval (40.19–157.22 words)."
)

writeLines(
  figure_caption,
  con = file.path(
    output_folder,
    "Figure_1_caption.txt"
  )
)


############################################################
# 27. VERIFY THAT ONLY THE PNG FIGURE EXISTS
#
# If an old standalone figure PDF remains from an earlier
# version of the script, report it so it can be removed.
############################################################

old_figure_pdf <- file.path(
  output_folder,
  "Figure_1_bootstrap_speaking_turn_length.pdf"
)

if (
  file.exists(old_figure_pdf)
) {
  warning(
    paste0(
      "An old standalone Figure 1 PDF still exists at: ",
      old_figure_pdf,
      "\n",
      "This script no longer generates that PDF. ",
      "Delete it manually if it is no longer needed."
    )
  )
}


############################################################
# 28. VERIFY FIGURE PNG EXISTS
############################################################

if (
  !file.exists(figure_png)
) {
  stop(
    "STOP: Figure 1 PNG was not created."
  )
}


############################################################
# 29. FINAL SAFETY CHECK
#
# The script must never create paper.pdf.
############################################################

paper_outputs <- list.files(
  output_folder,
  pattern = "^paper.*\\.pdf$",
  ignore.case = TRUE
)

if (
  length(paper_outputs) > 0
) {
  stop(
    paste0(
      "STOP: A paper PDF exists in the output directory: ",
      paste(
        paper_outputs,
        collapse = ", "
      ),
      "."
    )
  )
}


############################################################
# 30. FINAL MESSAGE
############################################################

cat("\n")
cat("============================================\n")
cat("FIGURE 1 REPRODUCTION COMPLETE\n")
cat("============================================\n\n")

cat(
  "Published paper PDF was not modified by this script.\n"
)

cat(
  "Published statistical values were verified.\n"
)

cat(
  "Exactly 10,000 bootstrap resamples were generated.\n"
)

cat(
  "Standalone Figure 1 saved ONLY as a 600-dpi PNG.\n"
)

cat(
  "No standalone Figure 1 PDF is generated.\n"
)

cat(
  "Y-axis: 0, 500, 1,000, 1,500 bootstrap resamples ",
  "per bin.\n",
  sep = ""
)

cat(
  "Output directory: ",
  output_folder,
  "\n",
  sep = ""
)

############################################################
# END
############################################################

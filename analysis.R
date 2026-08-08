############################################################
# CLEAN SUPREME COURT TRANSCRIPT EXTRACTION
############################################################

library(pdftools)
library(stringr)
library(dplyr)
library(ggplot2)
library(readr)

############################################################
# 1. SELECT PDF
############################################################

pdf_file <- "data/transcript.pdf"

############################################################
# 2. EXTRACT PDF TEXT
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
# 3. ACTUAL SPEAKER PATTERN
#
# Only recognize actual judges and attorneys.
#
# This prevents entries such as:
#
# APPEARANCES
# ORAL ARGUMENT OF
# REBUTTAL ARGUMENT OF
#
# from becoming "speakers."
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
# 4. RECONSTRUCT ACTUAL SPEAKING TURNS
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
  
  ##########################################################
  # NEW SPEAKER
  ##########################################################
  
  if (!is.na(match[1, 1])) {
    
    started <- TRUE
    
    ########################################################
    # Save previous turn
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
    # Start new turn
    ########################################################
    
    current_speaker <- str_trim(
      match[1, 2]
    )
    
    current_text <- match[1, 3]
    
  }
  
  ##########################################################
  # CONTINUATION OF CURRENT SPEAKER
  ##########################################################
  
  else if (started && !is.null(current_speaker)) {
    
    ########################################################
    # Remove Heritage footer
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
    # Remove transcript header
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
    # Remove page/line numbers
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
    # Ignore empty lines
    ########################################################
    
    if (
      nchar(cleaned_line) == 0
    ) {
      next
    }
    
    ########################################################
    # Ignore lines consisting only of numbers
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
    # Add continuation text
    ########################################################
    
    current_text <- paste(
      current_text,
      cleaned_line
    )
  }
}

############################################################
# 5. SAVE FINAL SPEAKING TURN
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
# 6. REMOVE NON-SPOKEN TRANSCRIPT LABELS
############################################################

utterances <- utterances %>%
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
# 7. REMOVE VERY SHORT ENTRIES
############################################################

utterances <- utterances %>%
  filter(
    nchar(text) >= 5
  )

############################################################
# 8. CALCULATE WORD COUNTS
############################################################

utterances <- utterances %>%
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
# 9. VERIFY EXTRACTION
############################################################

cat("\n")
cat("============================================\n")
cat("CLEAN TRANSCRIPT EXTRACTION\n")
cat("============================================\n\n")

cat(
  "Speaking turns:",
  nrow(utterances),
  "\n"
)

cat(
  "Speakers:",
  length(unique(utterances$speaker)),
  "\n\n"
)

print(
  sort(
    unique(
      utterances$speaker
    )
  )
)

############################################################
# 10. CHECK FOR PDF ARTIFACTS
############################################################

artifact_check <- utterances %>%
  filter(
    str_detect(
      text,
      "Heritage Reporting|Official - Subject|ORAL ARGUMENT OF|REBUTTAL ARGUMENT OF"
    )
  )

cat("\n")
cat(
  "Remaining transcript artifacts:",
  nrow(artifact_check),
  "\n"
)

if (nrow(artifact_check) > 0) {
  
  print(
    artifact_check
  )
  
  stop(
    "STOP: PDF artifacts remain in extracted speaking turns."
  )
}

############################################################
# 11. OBSERVED STATISTICS
############################################################

observed_n_turns <- nrow(
  utterances
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

cat("\n")
cat("============================================\n")
cat("OBSERVED RESULTS\n")
cat("============================================\n")

cat(
  "Speaking turns:",
  observed_n_turns,
  "\n"
)

cat(
  "Mean words per turn:",
  round(observed_mean_words, 2),
  "\n"
)

cat(
  "Median words per turn:",
  round(observed_median_words, 2),
  "\n"
)

cat(
  "Question-containing turns:",
  observed_question_count,
  "\n"
)

cat(
  "Question-containing turns (%):",
  round(observed_question_percent, 2),
  "%\n"
)

############################################################
# 12. EXACTLY 10,000 BOOTSTRAP SIMULATIONS
############################################################

n_simulations <- 10000

set.seed(
  20260808
)

simulation_results <- data.frame(
  simulation = 1:n_simulations,
  mean_words = numeric(n_simulations),
  question_percent = numeric(n_simulations)
)

############################################################
# 13. RUN BOOTSTRAP
############################################################

for (i in 1:n_simulations) {
  
  simulated_turns <- sample(
    1:nrow(utterances),
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
# 14. BOOTSTRAP RESULTS
############################################################

mean_words_lower <- quantile(
  simulation_results$mean_words,
  0.025
)

mean_words_upper <- quantile(
  simulation_results$mean_words,
  0.975
)

question_lower <- quantile(
  simulation_results$question_percent,
  0.025
)

question_upper <- quantile(
  simulation_results$question_percent,
  0.975
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
# 15. SUMMARY TABLE
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
  
  simulation_mean = c(
    simulation_mean_words,
    simulation_mean_questions
  ),
  
  simulation_sd = c(
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

print(
  results_summary
)

############################################################
# 16. ONE FIGURE ONLY
############################################################

plot1 <- ggplot(
  simulation_results,
  aes(
    x = mean_words
  )
) +
  
  geom_histogram(
    bins = 40,
    boundary = 0
  ) +
  
  geom_vline(
    xintercept = observed_mean_words,
    linewidth = 1
  ) +
  
  labs(
    title =
      "10,000 Bootstrap Resamples of Speaking-Turn Length",
    
    subtitle =
      "Vertical line = observed transcript mean",
    
    x =
      "Mean words per speaking turn",
    
    y =
      "Number of simulations"
  ) +
  
  theme_minimal()

print(
  plot1
)
############################################################
# 17. SAVE OUTPUTS
############################################################
if (!dir.exists("output")) {
  dir.create("output")
}
output_folder <- "output"

write_csv(
  utterances,
  file.path(
    output_folder,
    "extracted_speaking_turns.csv"
  )
)

write_csv(
  simulation_results,
  file.path(
    output_folder,
    "10000_simulation_results.csv"
  )
)

write_csv(
  results_summary,
  file.path(
    output_folder,
    "simulation_summary.csv"
  )
)

ggsave(
  filename = file.path(
    output_folder,
    "Figure_1_bootstrap_speaking_turn_length.png"
  ),
  plot = plot1,
  width = 7,
  height = 5,
  dpi = 300
)

############################################################
# 18. FINAL CHECK
############################################################

cat("\n")
cat("============================================\n")
cat("PROJECT COMPLETE\n")
cat("============================================\n\n")

cat(
  "Exactly 10,000 bootstrap simulations completed.\n"
)

cat(
  "Speaking turns:",
  nrow(utterances),
  "\n"
)

cat(
  "Figures produced: 1\n"
)

cat(
  "Transcript artifacts remaining:",
  nrow(artifact_check),
  "\n"
)
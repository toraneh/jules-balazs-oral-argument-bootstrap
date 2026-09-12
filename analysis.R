# ============================================================
# Simulating Variation in YouTube View Counts
# Sansad TV | RS Question Hour, 07 August 2026
#
# Method:
#   1. Take the single observed view count as the expected
#      value (lambda) of a Poisson distribution.
#   2. Simulate 10,000 draws from that distribution.
#   3. Summarize the simulated distribution (mean, SD, range,
#      95% empirical simulation interval).
#   4. Produce one figure.
#
# This is a simulation around one observed count, not a
# forecast of future views and not a validated claim that
# YouTube view counts follow a Poisson process.
#
# R 4.5.0, base R only (no packages required).
# ============================================================


# ------------------------------------------------------------
# 1. Reproducibility settings
# ------------------------------------------------------------

observed_views <- 3306

set.seed(123)

n_sim <- 10000

output_dir <- "output"

dir.create(
  output_dir,
  showWarnings = FALSE,
  recursive = TRUE
)


# ------------------------------------------------------------
# 2. Simulation
# ------------------------------------------------------------

simulated_views <- rpois(n_sim, observed_views)

sim_mean <- mean(simulated_views)
sim_sd   <- sd(simulated_views)
sim_min  <- min(simulated_views)
sim_max  <- max(simulated_views)
sim_ci   <- quantile(simulated_views, c(0.025, 0.975))


# ------------------------------------------------------------
# 3. Print results
# ------------------------------------------------------------

cat("\n")
cat("YouTube View Count Simulation (Poisson)\n")
cat("----------------------------------------\n")
cat("Observed views:        ", observed_views, "\n")
cat("Simulations:           ", n_sim, "\n")
cat("Simulated mean:        ", round(sim_mean, 1), "\n")
cat("Simulated SD:          ", round(sim_sd, 1), "\n")
cat("Simulated min:         ", sim_min, "\n")
cat("Simulated max:         ", sim_max, "\n")
cat("95% simulation interval:", sim_ci[1], "-", sim_ci[2], "\n")
cat("\n")


# ------------------------------------------------------------
# 4. Save summary statistics
# ------------------------------------------------------------

summary_table <- data.frame(
  statistic = c(
    "observed_views",
    "n_simulations",
    "simulated_mean",
    "simulated_sd",
    "simulated_min",
    "simulated_max",
    "ci_2.5_percent",
    "ci_97.5_percent"
  ),
  value = c(
    observed_views,
    n_sim,
    sim_mean,
    sim_sd,
    sim_min,
    sim_max,
    sim_ci[1],
    sim_ci[2]
  )
)

write.csv(
  summary_table,
  file = file.path(output_dir, "simulation_summary.csv"),
  row.names = FALSE
)


# ------------------------------------------------------------
# 5. Figure: high-resolution PNG (600 dpi; dots per inch)
# ------------------------------------------------------------

figure_png <- file.path(
  output_dir,
  "Figure_1.png"
)

png(
  figure_png,
  width = 8, height = 5.5, units = "in", res = 600
)

par(
  family = "serif",
  mar = c(5, 5, 4, 2),
  cex.main = 1.3,
  cex.lab = 1.1,
  cex.axis = 0.95
)

hist(
  simulated_views,
  breaks = 50,
  main = "Simulated YouTube View Counts",
  xlab = "View Count",
  ylab = "Frequency",
  col = "#ADD8E6",
  border = "white",
  xlim = c(3050, 3550),
  ylim = c(0, 800),
  yaxp = c(0, 800, 4),
  xaxt = "n",
  las = 1
)

# Custom x-axis with thousands separators (e.g. "3,300"), which
# reads more clearly than bare "3300" for a view-count figure.
x_ticks <- seq(3100, 3500, by = 100)
axis(
  1,
  at = x_ticks,
  labels = format(x_ticks, big.mark = ",", scientific = FALSE)
)

# Light gridlines drawn first, then bars redrawn on top so the
# gridlines sit behind (not over) the histogram bars.
abline(h = seq(0, 800, by = 100), col = "gray90", lty = 1, lwd = 0.5)

hist(
  simulated_views,
  breaks = 50,
  col = "#ADD8E6",
  border = "white",
  add = TRUE
)

# Observed value
abline(v = observed_views, col = "firebrick", lwd = 2)

# Mean of simulated distribution (dashed, for comparison)
abline(v = sim_mean, col = "gray40", lwd = 1.5, lty = 2)

legend(
  "topright",
  legend = c(
    paste0("Observed views (", observed_views, ")"),
    paste0("Simulated mean (", round(sim_mean, 1), ")")
  ),
  col = c("firebrick", "gray40"),
  lwd = c(2, 1.5),
  lty = c(1, 2),
  bty = "n",
  cex = 0.9
)

mtext(
  paste0(
    "n = 10,000 simulations | SD = ", round(sim_sd, 1),
    " | 95% CI: [", sim_ci[1], ", ", sim_ci[2], "]"
  ),
  side = 3, line = 0.3, cex = 0.85, col = "gray30"
)

box(col = "gray50")

dev.off()


# ------------------------------------------------------------
# 6. Completion message
# ------------------------------------------------------------

cat("Files written to: ", output_dir, "\n")
cat(" - simulation_summary.csv\n")
cat(" - Figure_1.png\n")

# ============================================================
# END
# ============================================================

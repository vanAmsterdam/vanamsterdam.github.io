# Run from the repository root:
# Rscript posts/261029-survival-circle/scripts/render-curves.R
# Data copied from survival-circle/sources/nl-men-table.csv (CBS 37360ned,
# period 2025, men; CC BY 4.0), conditional on being alive at age 18.
args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)])
post <- dirname(dirname(normalizePath(script)))
data <- read.csv(file.path(post, "data", "nl-men-2025.csv"))

draw_curve <- function(key, label, ymax, ticks, midpoint = FALSE) {
  filenames <- c(S = "survival", F = "incidence", f = "density",
                 h = "hazard", H = "cumulative-hazard")
  x <- if (midpoint) data$midage else data$age
  y <- data[[key]]
  svglite::svglite(file.path(post, "images", paste0("curve-", filenames[[key]], ".svg")),
      width = 6.4, height = 3.9, pointsize = 12, bg = "white")
  par(mar = c(4.2, 4.5, 1.4, 1), mgp = c(2.7, 0.7, 0),
      col.axis = "#48515B", col.lab = "#27313D", fg = "#ABB3BC",
      family = "sans", las = 1)
  plot(x, y, type = "n", xlim = c(18, 100), ylim = c(0, ymax),
       xaxs = "i", yaxs = "i", axes = FALSE, xlab = "Age (years)", ylab = label)
  abline(h = ticks, col = "#E7EBEF", lwd = 0.8)
  axis(1, at = c(20, 40, 60, 80, 100), tck = -0.015)
  axis(2, at = ticks, tck = -0.015)
  # The markers are the annual life-table values, not a fitted continuous model.
  lines(x, y, col = "#244F78", lwd = 2)
  points(x, y, pch = 16, cex = 0.35, col = "#244F78")
  if (key %in% c("S", "F")) {
    value <- y[data$age == 60]
    points(60, value, pch = 21, bg = "#A52B35", col = "white", cex = 1.1)
    text(60, value, if (key == "S") "94% at age 60" else "6% by age 60",
         pos = if (key == "S") 1 else 3, offset = 0.8, cex = 0.9, col = "#A52B35")
  }
  if (key == "f") {
    peak <- which.max(y)
    points(x[peak], y[peak], pch = 21, bg = "#A52B35", col = "white", cex = 1.1)
    text(x[peak] - 3, y[peak], "Peak around age 88", pos = 2,
         cex = 0.9, col = "#A52B35")
  }
  dev.off()
}

draw_curve("S", "Survival S(t)", 1, c(0, 0.5, 1))
draw_curve("F", "Cumulative incidence F(t)", 1, c(0, 0.5, 1))
draw_curve("f", "Deaths per year of age", 0.05, c(0, 0.02, 0.04), TRUE)
draw_curve("h", "Hazard (per year)", 0.5, c(0, 0.2, 0.4), TRUE)
draw_curve("H", "Cumulative hazard H(t)", 4.5, c(0, 2, 4))

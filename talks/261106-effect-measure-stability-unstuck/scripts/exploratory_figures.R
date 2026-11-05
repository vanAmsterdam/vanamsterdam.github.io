# Run: Rscript scripts/exploratory_figures.R
# Descriptive figures only: all canonical per-study data, before fit filters.
library(ggplot2)
library(dplyr)
library(patchwork)

script <- sub('^--file=', '', grep('^--file=', commandArgs(), value = TRUE)[1])
out <- file.path(dirname(dirname(normalizePath(script))), 'figs', 'exploratory')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
source <- path.expand('~/dev/effect-measure-stability/data/processed/per_study_data.csv')
d <- read.csv(source, stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(all(d$n.c > 0), all(d$event.c >= 0 & d$event.c <= d$n.c))
labels <- d |> group_by(ma_id) |> summarise(across(c(monotonicity, expected_treatment_effect), n_distinct))
stopifnot(all(labels$monotonicity == 1), all(labels$expected_treatment_effect == 1))
g <- d |> group_by(ma_id) |> summarise(k = n_distinct(trial_id), monotonicity = first(monotonicity), direction = first(expected_treatment_effect))
mono <- g$monotonicity %in% c('certain', 'likely')
eligible <- g$k >= 5
c <- d |> distinct(ma_id, trial_id, event.c, n.c, .keep_all = TRUE) |> mutate(rate = event.c/n.c)
med <- c |> group_by(ma_id) |> summarise(rate = median(rate))

theme_set(theme_classic(base_size = 16) + theme(plot.title = element_text(size = 20), plot.subtitle = element_text(size = 15), plot.margin = margin(12, 15, 12, 12), legend.position = 'bottom'))
save_plot <- function(p, name, width = 12, height = 5.8) {
  for (ext in c('png', 'svg')) ggsave(file.path(out, paste0(name, '.', ext)), p, width = width, height = height, dpi = 180, bg = 'white')
}

counts <- g |> count(k)
p <- ggplot(counts, aes(k, n)) +
  geom_col(aes(fill = k >= 5), width = .8, show.legend = FALSE) +
  scale_fill_manual(values = c('FALSE' = '#AAB4BE', 'TRUE' = '#0072B2')) +
  geom_vline(xintercept = 4.5, linetype = 'dashed') +
  annotate('text', x = Inf, y = Inf, hjust = 1.05, vjust = 1.2, size = 6,
           label = sprintf('%s meta-analyses\n%d with ≥5 RCTs (%.1f%%)\nMedian: %.0f RCTs', format(nrow(g), big.mark = ','), sum(eligible), mean(eligible)*100, median(g$k))) +
  scale_x_continuous(limits = c(0, max(g$k)+1), breaks = seq(0, 45, 5)) +
  labs(title = 'Distinct RCTs per meta-analysis', x = 'Number of distinct trials', y = 'Number of meta-analyses')
save_plot(p, 'rcts-per-meta-analysis', 10, 5.6)

monotonic_plot <- function(x, title) {
  tab <- x |> count(monotonicity, direction) |>
    mutate(monotonicity = factor(monotonicity, c('certain', 'likely', 'unlikely')),
           direction = factor(direction, c('decrease', 'increase', 'unknown')))
  totals <- tab |> group_by(monotonicity) |> summarise(n = sum(n))
  ymax <- max(totals$n)*1.25
  ggplot(tab, aes(monotonicity, n, fill = direction)) +
    geom_col(position = position_stack(reverse = TRUE)) +
    geom_text(aes(label = ifelse(n >= ymax*.04, n, '')), position = position_stack(vjust = .5, reverse = TRUE), color = 'white', size = 4.5) +
    geom_text(data = totals, aes(monotonicity, n, label = n), inherit.aes = FALSE, vjust = -.5, size = 5) +
    scale_fill_manual(values = c(decrease = '#0072B2', increase = '#D55E00', unknown = '#AAB4BE'), drop = FALSE, labels = c('Decrease', 'Increase', 'Unknown')) +
    scale_y_continuous(limits = c(0, ymax), expand = expansion(mult = c(0, .02))) +
    labs(title = title, subtitle = sprintf('Certain or likely: %d / %s', sum(x$monotonicity %in% c('certain', 'likely')), format(nrow(x), big.mark = ',')), x = 'Assessed monotonicity', y = 'Number of meta-analyses', fill = 'Expected effect on P(Y=1)')
}
p <- (monotonic_plot(g, 'All meta-analyses') + monotonic_plot(g[eligible, ], 'Meta-analyses with ≥5 RCTs')) +
  plot_layout(guides = 'collect')
save_plot(p, 'monotonicity-and-direction', height = 6.2)

baseline_plot <- function(values, title) {
  # Match numpy's bins: [left, right), with the last bin including 1.
  bins <- pmin(floor(values*25), 24L)
  h <- data.frame(mid = (0:24+.5)/25, n = tabulate(bins+1, nbins = 25))
  ggplot(h, aes(mid, n)) + geom_col(width = .04, fill = '#0072B2', color = 'white') +
    scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, .2), labels = scales::label_percent(), expand = expansion(mult = 0)) +
    labs(title = title, subtitle = sprintf('n = %s; median = %.1f%%', format(length(values), big.mark = ','), median(values)*100), x = 'Observed control-arm event proportion', y = 'Count')
}
p <- (baseline_plot(c$rate, 'Control-arm observations') + baseline_plot(med$rate, 'Within-meta-analysis median')) +
  plot_annotation(caption = 'Zero and all-event controls retained; trials may recur across meta-analyses.')
save_plot(p, 'baseline-rates')

direction_counts <- function(x) as.list(table(factor(x, c('decrease', 'increase', 'unknown'))))
summary <- list(source = source, sha256 = digest::digest(file = source, algo = 'sha256'),
  meta_analyses = nrow(g), at_least_5_trials = sum(eligible), certain_or_likely = sum(mono),
  certain_or_likely_at_least_5 = sum(mono & eligible),
  monotonic_direction_counts = direction_counts(g$direction[mono]),
  monotonic_direction_counts_at_least_5 = direction_counts(g$direction[mono & eligible]),
  control_observations = nrow(c), zero_event_controls = sum(c$rate == 0), all_event_controls = sum(c$rate == 1),
  control_rate_median = median(c$rate), ma_median_control_rate_median = median(med$rate),
  definitions = list(MA = 'cochrane_id × comparison × outcome × subgroup (canonical ma_id)',
    RCT_count = 'distinct trial_id within ma_id', monotonic = 'screened certain or likely, not empirically established',
    baseline = 'event.c/n.c; deduplicate identical control counts within ma_id/trial_id; retain distinct observations',
    scope = 'all canonical per-study rows; no convergence or effect-direction selection'))
# Check agreement with earlier output when the source data are unchanged.
previous_path <- file.path(out, 'provenance.json')
if (file.exists(previous_path)) {
  previous <- jsonlite::read_json(previous_path, simplifyVector = TRUE)
  if (identical(previous$sha256, summary$sha256)) {
    for (name in c('meta_analyses', 'at_least_5_trials', 'certain_or_likely', 'certain_or_likely_at_least_5', 'control_observations', 'zero_event_controls', 'all_event_controls', 'control_rate_median', 'ma_median_control_rate_median')) {
      stopifnot(isTRUE(all.equal(as.numeric(previous[[name]]), as.numeric(summary[[name]]))))
    }
  }
}
write.csv(g, file.path(out, 'meta-analysis-descriptives.csv'), row.names = FALSE)
jsonlite::write_json(summary, previous_path, auto_unbox = TRUE, pretty = TRUE, digits = NA)
writeLines(capture.output(sessionInfo()), file.path(out, 'R-session-info.txt'))
print(summary)

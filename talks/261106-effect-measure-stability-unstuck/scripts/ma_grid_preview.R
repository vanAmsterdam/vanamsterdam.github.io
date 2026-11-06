# Reuse the original ggplot definitions without running its export commands.
repo <- path.expand("~/dev/effect-measure-stability")
source_lines <- readLines(file.path(repo, "analysis/plot_monotonic_study_grids.R"))
stop_at <- grep('^dir.create\\(output_dir', source_lines)[1]
definitions <- source_lines[seq_len(stop_at - 1L)]
definitions[grep('^input_file <-', definitions)] <- sprintf(
  'input_file <- "%s"', file.path(repo, "data/processed/per_study_data.csv"))
eval(parse(text = definitions))
dest <- "figs/ma-grid-preview"
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
for (direction in c("decrease", "increase")) {
  # First two MAs in original PDF order, without selecting for visual agreement.
  ids <- head(theory_estimates$ma_id[
    theory_estimates$expected_treatment_effect == direction], 2L)
  p <- make_grid("odds", ids) +
    labs(title = NULL, subtitle = NULL, caption = NULL) +
    theme(legend.position = "none", text = element_text(size = 13),
          strip.text.y = element_text(size = 8),
          plot.margin = margin(12, 24, 12, 24))
  ggsave(file.path(dest, paste0(direction, ".png")), p,
         width = 12, height = 4.5, dpi = 180)
  ggsave(file.path(dest, paste0(direction, ".svg")), p,
         width = 12, height = 4.5, device = svglite::svglite)
}
for (axis in c("probability", "odds", "inverse_odds")) {
  filename <- paste0("monotonic_studies_", axis, ".pdf")
  file.copy(file.path(repo, "output/pdf", filename),
            file.path(dest, filename), overwrite = TRUE)
}

library(data.table)
library(readr)
library(stringr)
library(purrr)
library(ggplot2); theme_set(theme_bw())

lns <- readr::read_lines('timings.txt')

timings <- data.table(raw_string=lns)
timings[, string:=str_trim(raw_string)] # remove white space
timings <- timings[str_starts(string, "Rscript|julia|python")] # remove warings / errors
timings[, command:=word(string)]
timings[command=='Rscript', language:='r']
timings[command=='python', language:='jax']
timings[command=='julia', language:='julia']
timings[, time_str:=str_extract(string, "(?<=cpu\\ )(.*)(?= total)")]
timings[, milliseconds:=str_extract(time_str, "(\\d+)$")]
timings[, seconds:=str_extract(time_str, "(\\d+)(?=.)")]
timings[, minutes:=str_extract(time_str, "(\\d+)(?=:)")]
timings[, nreps:=as.integer(str_extract(string, "(\\d+)(?= nreps)"))]
timings[, nthreads:=as.integer(str_extract(string, "(\\d+)(?= nthreads)"))]
max_threads <- max(timings$nthreads, na.rm=T)

numvars <- c('minutes', 'seconds', 'milliseconds')
walk(numvars, ~set(timings, j=.x, value=as.numeric(timings[[.x]])))
timings[is.na(minutes), minutes:=0]
timings[, sec_total:=60*minutes + seconds + milliseconds / 1000]
timings[, min_total:=sec_total / 60]
timings[is.na(nthreads) & language == 'jax', nthreads:=max_threads]
timings[is.na(nthreads) & language %in% c('r', 'julia'), nthreads:=1L]

# add some vars
timings[, n_per_min:=nreps / min_total]
timings[, log_n_per_min:=log(n_per_min)]

ggplot(timings[nthreads==max_threads], aes(x=nreps, y=n_per_min, col=language)) +
  geom_point() + geom_line() + 
  scale_x_log10() + scale_y_log10() + 
  ggtitle("time to run experiments")

tabcols <- c('nreps', 'nthreads', 'min_total', 'log_n_per_min', 'language')
timings[, .SD, .SDcols=tabcols]



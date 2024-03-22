# rspeed
args = commandArgs(trailingOnly = T)
if (length(args) == 0) {
  nreps = 100
  nthreads = 1
} else if (length(args) == 1) {
  nreps = as.integer(args[1])
  nthreads = 1
} else {
  nreps = as.integer(args[1])
  nthreads = as.integer(args[2])
  suppressMessages(library(furrr))
  plan(multisession, workers=nthreads)
}

make_data <- function(n=1e3L) {
    x_vec = rnorm(n*10)
    X_full = matrix(x_vec, ncol=10)
    eta = rowSums(X_full)
    y = eta > 0
    # return only first 9 column to have some noise
    X = X_full[,1:9]
    return(list(X=X,y=y))
}

solve <- function(...) {
  data = make_data()
  fit = glm(data$y~data$X-1, family='binomial')
  coefs = coef(fit)
  return(coefs)
}

if (nthreads == 1) {
    set.seed(240316)
    params <- lapply(1:nreps, solve)
} else {
    params <- future_map(1:nreps, solve, .options=furrr_options(seed=240316))
}
outmat <- do.call(rbind, params)
means <- colMeans(outmat)
print(means[1])


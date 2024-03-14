# rspeed
library(purrr)
args = commandArgs(trailingOnly = T)
if (length(args) == 0) {
  nreps = 100
} else {
  nreps = as.integer(args[1])
}

## single threaded
make_data <- function(n=1e3L) {
    x = rnorm(n*10)
    X = matrix(x, ncol=10)
    eta = rowSums(X)
    y = eta > 0
    # return only first 9 column to have some noise
    X = X[,1:9]
    return(list(X=X,y=y))
}

solve <- function(data) {
  fit = glm(data$y~data$X-1, family='binomial')
  return(coef(fit))
}

one_iter <- function(...) {
  data = make_data()
  coefs = solve(data)
  return(coefs)
}

res <- map(1:nreps, one_iter)
outmat <- do.call(rbind, res)
print(colMeans(outmat))

---
title: Finding the functional form for multiple linear regression
output: pdf_document
date: '2019-08-16'
tags:
- statistics 
- simulations
permalink: '/posts/2019-08-16-lr-functional-form/'
postname: '2019-08-16-lr-functional-form'
pdf: true
rmd: true
header-includes:
  - \usepackage{mathrsfs}
---


```r
require(ggplot2)
set.seed(12345)
N = 1000
x <- runif(N, min = 0, max=2*pi)
w <- .5*x + sin(x) + rnorm(N, sd=.25)
sy <- rnorm(N, sd=.1)

plot(x, w)
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-1.png)

```r
lx <- lm(x~w)
lw <- lm(w~x)

y <- x^2 + w + sy

plot(y, x)
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-2.png)

```r
plot(y, w)
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-3.png)

```r
ggplot(data.frame(x=x,w=w,y=y), aes(x=x, y=w,col=y, size=y)) + 
  geom_point() + theme_minimal()
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-4.png)

```r
lyx <- lm(y~x)
plot(w, resid(lyx))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-5.png)

```r
plot(resid(lw), resid(lyx))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-6.png)

```r
plot(y, resid(lyx))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-7.png)

```r
lyw <- lm(y~w)
plot(x, resid(lyw))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-8.png)

```r
# partial regression plot
plot(resid(lx), resid(lyw))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-9.png)

```r
plot(y, resid(lyw))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-10.png)

```r
lyxw <- lm(y~x+w)
plot(x, resid(lyxw))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-11.png)

```r
plot(w, resid(lyxw))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-12.png)

```r
plot(y, resid(lyxw))
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-13.png)

```r
lm(y~x+w)
```

```
## 
## Call:
## lm(formula = y ~ x + w)
## 
## Coefficients:
## (Intercept)            x            w  
##      -6.695        6.303        0.971
```

```r
lm(resid(lyw)~resid(lx))
```

```
## 
## Call:
## lm(formula = resid(lyw) ~ resid(lx))
## 
## Coefficients:
## (Intercept)    resid(lx)  
##  -1.360e-15    6.303e+00
```

```r
# the solution (partial residual plot):
plot(x, resid(lyxw)+coef(lyxw)['x']*x)
```

![plot of chunk unnamed-chunk-1](/Users/vanAmsterdam/git/vanamsterdam.github.io/posts/figures/2019-08-16-lr-functional-form/unnamed-chunk-1-14.png)

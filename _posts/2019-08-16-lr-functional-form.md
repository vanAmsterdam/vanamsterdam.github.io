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

A frequent question that comes up when modeling continuous outcomes with multiple linear regression 
is what the correct functional form for the relationship between the independent variables is.
TLDR: the answer is a [partial residual plot](https://en.wikipedia.org/wiki/Partial_residual_plot). 
Here I will generate some data to illustrate this



```r
require(ggplot2)
set.seed(12345)
N = 1000
x <- runif(N, min = 0, max=2*pi)
w <- .5*x + sin(x) + rnorm(N, sd=.25)
sy <- rnorm(N, sd=.1)
y <- x + w + sy
df = data.frame(x=x,w=w,y=y)
```

The data consists of two real-valued 'independent' variables $x,w$, 
where 
$$x\sim U(0, 2 \pi)$$
$$w \sim \frac{x}{2} + sin(x) + \epsilon_w \sim N(0, 0.25)$$
In reality, $y$ is linear in both $x$ and $w$.
A plot of the data:


```r
ggplot(df, aes(x=x, y=w,col=y, size=y)) + 
  geom_point() + theme_minimal()
```

![plot of chunk xwy](posts/figures/2019-08-16-lr-functional-form/xwy-1.png)

Let's say we're particualrly interested in the relationship between $y$ and $x$, both conditional on $w$.
Looking at the *marginal* assocation between $y$ and $x$ with a scatterplot will set us on the wrong foot, 
because of the assocation between $x$ and $w$.


```r
ggplot(df, aes(x=x,y=y)) + 
  geom_point() + 
  ggtitle("Marginal association between x and y") + 
  theme_minimal()
```

![plot of chunk marginal](posts/figures/2019-08-16-lr-functional-form/marginal-1.png)

To construct the correct plot, we can generate a partial residual plot, which is created with 

$$resid(y|x,w)+\beta_x x \sim x$$

Where $\beta_x$ is the regression coefficient found through linear regression of $y$ on $x$ and $w$
In a plot:


```r
lyxw <- lm(y~x+w)
ggplot(df, aes(x=x,y=resid(lyxw)+coef(lyxw)['x']*x)) + 
  geom_point() + 
  ggtitle("partial residual plot") + 
  theme_minimal()
```

![plot of chunk partresid](posts/figures/2019-08-16-lr-functional-form/partresid-1.png)

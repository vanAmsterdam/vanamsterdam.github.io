library(MASS)
library(ggplot2); theme_set(theme_bw())
library(data.table)
library(manipulate)
library(Rfast)

n = 1000

manipulate({
  # rho_boy = .9
  # rho_girl = .7
  # s_boy = 1.
  # s_girl = .7
  
  mu_boy = c(0, .5)
  mu_girl = c(0, 0)
  sigma_boy = matrix(c(s1_boy, rho_boy, rho_boy, s1_boy), nrow=2)
  sigma_girl = matrix(c(s1_girl, rho_girl, rho_girl, s1_girl), nrow=2)
  print(sigma_boy)
  print(sigma_girl)
  boys = mvrnorm(n, mu_boy, sigma_boy)
  girls = mvrnorm(n, mu_girl, sigma_girl)
  
  df <- as.data.table(rbind(boys, girls))
  colnames(df) <- c('age', 'length')
  df$sex <- rep(c('boy', 'girl'), each=n)
  
  p <- ggplot(df, aes(x=age, y=length, col=sex)) + geom_point()
  p
  
},
rho_boy=slider(0, 1),
s1_boy=slider(0,1),
s2_boy=slider(0,1),
rho_girl=slider(0, 1),
s1_girl=slider(0,1),
s2_girl=slider(0,1)
)

# manipulate({
  mu0_boy=2
  mu0_girl=1
  
  x_boys = rnorm(n, mu0_boy)
  x_girls = rnorm(n, mu0_girl)
  a_boy=.5
  b_boy=1.
  s_boy=.3
  a_girl=0
  b_girl=.6
  s_girl=.3
  y_boys = a_boy + b_boy * x_boys + rnorm(n, 0, s_boy)
  y_girls = a_girl + b_girl * x_girls + rnorm(n, 0, s_girl)
  
  df <- data.table(age=c(x_boys, x_girls), length=c(y_boys, y_girls))
  colnames(df) <- c('length', 'weight')
  df$sex <- rep(c('boy', 'girl'), each=n)
  p <- ggplot(df, aes(x=length, y=weight, col=sex)) + geom_point()
  p
  
# }#,
# mu0_boy=slider(0, 1,1),
# a_boy=slider(0, 1,1),
# b_boy=slider(0, 1,1),
# s_boy=slider(0,1,1),
# mu0_=slider(0, 1,1),
# a_girl=slider(0, 1,1),
# b_girl=slider(0, 1,1),
# s_girl=slider(0,1,1))
  
# r_boy = b_boy * 1 / s_boy  
# sn_boy = (s_boy^2 * (1-r_boy^2))
fwrite(df, "lenght_weight.csv") 
  
fit_boy = mvnorm.mle(df[sex=='boy', as.matrix(.SD), .SDcols=c('length', 'weight')])
fit_girl = mvnorm.mle(df[sex=='girl', as.matrix(.SD), .SDcols=c('length', 'weight')])
fit_boy
fit_girl

  




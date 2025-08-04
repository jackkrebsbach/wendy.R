
# %%
library(symengine)
library(deSolve)
source('R/WENDy.R')
# %%
set.seed(42)
goodwin <- function(u, p, t) {
  du1 <- p[[1]] / (36 + p[[2]] * u[[2]])  - p[[3]]
  du2 <- p[[4]] * u[[1]] - p[[5]]
  list(du1, du2)
}

npoints <- 100
p_star <- c(72, 1, 2, 1, 1)
p0 <- c(65, 2.5, 3, 1.5, 2)
u0 <- c(7, -10)
t_span <- c(0, 60); 

modelODE <- function(tvec, state, parameters) { list(as.vector(goodwin(state, parameters, tvec))) }

noise_sd <- 0.05
t_eval <- seq(t_span[1], t_span[2], length.out = npoints)
sol <- deSolve::ode( y = u0, times = t_eval, func = modelODE, parms = p_star)

noise <- matrix(rnorm(nrow(sol) * (ncol(sol) - 1), mean = 0, sd = noise_sd), nrow = nrow(sol))
U <- sol[,-1] + noise
tt <- matrix(sol[,1], ncol = 1)

plot(U[,2], cex = 0.5) 
points(U[,1], cex = 0.5, col = "red", pch = 16)

p <- WendySolver(goodwin, U, p0, tt, noise_sd, compute_svd_ = TRUE, optimize_ = TRUE) 

p_hat <- p$p_hat

sol_hat <- deSolve::ode(u0, t_eval, modelODE, p_hat)[ ,-1]
plot(U[,2], cex = 0.5) 
points(sol_hat[, 2], cex = 0.5, col="red")


cat("pstar:", paste(p_star, collapse = " "), "\n")
cat("phat:", paste(format(p_hat, digits = 3, scientific = FALSE), collapse = " "), "\n")

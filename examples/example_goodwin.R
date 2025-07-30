# Setup
library(symengine)
library(deSolve)
source('R/WENDy.R')
set.seed(42)


# Define RHS
goodwin <- function(u, p, t) {
  du1 <- p[[1]] / (2.15 + p[[3]] * u[[3]]^p[[4]]) - p[[2]] * u[[1]]
  du2 <- p[[5]] * u[[1]] - p[[6]] * u[[2]]
  du3 <- p[[7]] * u[[2]] - p[[8]] * u[[3]]
  list(du1, du2, du3)
}


# Generate noisy data
p_star <- c(3.4884, 0.0969, 1, 10, 0.0969, 0.0581, 0.0969, 0.0775)
u0 <- c(0.3617, 0.9137, 1.393)
p0 <- c(2, 0.05, 1.5, 13, 0.15, 0.12, 0.18, 0.10)
npoints <- 50; t_span <- c(0, 80); t_eval <- seq(t_span[1], t_span[2], length.out = npoints)


# Define input for deSolve
modelODE <- function(tvec, state, parameters) {
    list(as.vector(goodwin(state, parameters, tvec)))
}


# Solve
noise_ratio <- 0.05
sol <- deSolve::ode( y = u0, times = t_eval, func = modelODE, parms = p_star)
noise <- matrix(rnorm(nrow(sol) * (ncol(sol) - 1), mean = 0, sd = noise_ratio), nrow = nrow(sol))
U <- sol[,-1] + noise
tt <- matrix(sol[,1], ncol = 1)

plot(U[,3], cex = 0.5) 
points(U[,2], cex = 0.5, col = "red", pch = 16)
points(U[,1], cex = 0.5, col = "blue", pch = 16)


# Solve for parameters
source('R/WENDy.R')
p <- WendySolver(goodwin, U, p0, tt) # WENDy Solve

p_hat <- p$p_hat
sol_hat <- deSolve::ode(u0, t_eval, modelODE, p_hat)


# Compare data and data from estimated parameters
plot(sol_hat[, 2], cex = 0.5, col = "blue", pch = 16)  
points(U, cex = 0.5, col = "red", pch = 16)


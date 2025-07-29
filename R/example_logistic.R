# Setup
library(symengine)
library(deSolve)

source('R/WENDy.R')

set.seed(42)

# Define RHS
logistic <- function(u, p, t) {
  list(p[[1]] * u[[1]] - p[[2]] * u[[1]]^2)
}


# Generate noisy data
p_star <- c(1, 1)
u0 <- c(0.01)
p0 <- c(0.5, 0.5)

npoints <- 100; t_span <- c(0, 10); t_eval <- seq(t_span[1], t_span[2], length.out = npoints)

# Define input for deSolve
modelODE <- function(tvec, state, parameters) {
    list(as.vector(logistic(state, parameters, tvec)))
}

# Solve
sol <- deSolve::ode( y = u0, times = t_eval, func = modelODE, parms = p_star)
U <- matrix(c(sol[,2] + 0.05*rnorm(npoints)), ncol = 1)
tt <- matrix(sol[,1], ncol = 1)

# Plot data
plot(U, cex = 0.5) 

# Solve for parameters
data <- WendySolver(logistic, U, p0, tt, compute_svd_ = TRUE)
p_hat <- data$p_hat

sol_hat <- deSolve::ode( y = u0, times = t_eval, func = modelODE, parms = p_hat)

# Compare data and data from estimated parameters
plot(sol_hat[, 2], cex = 0.5, col = "blue", pch = 16)  
points(U, cex = 0.5, col = "red", pch = 16)

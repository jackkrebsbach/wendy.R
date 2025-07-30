{
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
u0 <- c(0.005)
p0 <- c(0.25, 0.25)
npoints <- 250; t_span <- c(0, 10); t_eval <- seq(t_span[1], t_span[2], length.out = npoints)


# Define input for deSolve
modelODE <- function(tvec, state, parameters) {
    list(as.vector(logistic(state, parameters, tvec)))
}


# Solve
noise_ratio <- 0.05
sol <- deSolve::ode( y = u0, times = t_eval, func = modelODE, parms = p_star)
U <- matrix(c(sol[,2] + rnorm(npoints, mean = 0, sd = noise_ratio)), ncol = 1)
tt <- matrix(sol[,1], ncol = 1)
plot(U, cex = 0.5) 

}

# Solve for parameters
source('R/WENDy.R')
data <- WendySolver(logistic, U, p0, tt) 

p_hat <- data$p_hat
sol_hat <- deSolve::ode(u0, t_eval, modelODE, p_hat)

# Compare data and data from estimated parameters
plot(sol_hat[, 2], cex = 0.5, col = "blue", pch = 16)  
points(U, cex = 0.5, col = "red", pch = 16)


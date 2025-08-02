library(symengine)
library(deSolve)

{
# Define RHS
logistic <- function(u, p, t) {
  list(p[[1]] * u[[1]] - p[[2]] * u[[1]]^2)
}

# Generate noisy data
noise_sd <- 0.05
p_star <- c(1, 1)
u0 <- c(0.01)
p0 <- c(0.5, 0.5)
npoints <- 152; 
t_span <- c(0, 10); t_eval <- seq(t_span[1], t_span[2], length.out = npoints)


# Define input for deSolve
modelODE <- function(tvec, state, parameters) {
    list(as.vector(logistic(state, parameters, tvec)))
}

# Solve
set.seed(42)
sol <- deSolve::ode( y = u0, times = t_eval, func = modelODE, parms = p_star)
U <- matrix(c(sol[,2] + rnorm(npoints, mean = 0, sd = noise_sd)), ncol = 1)
tt <- matrix(sol[,1], ncol = 1)
plot(U, cex = 0.5) 

}

# Solve for parametersj
source('R/WENDy.R')
res <- WendySolver(logistic, U, p0, tt, noise_sd) 

res$plot_radius_selection()

p_hat <- res$p_hat

# Compare data and data from estimated parameters
sol_hat <- deSolve::ode(u0, t_eval, modelODE, p_hat)
plot(U, cex = 0.5) 
points(sol[, 2], cex = 0.5, col = "blue")
points(sol_hat[, 2], cex = 0.5, col = "red")

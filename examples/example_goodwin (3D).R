# %%
source('R/WENDy.R')
library(symengine)
library(deSolve)

# %%
set.seed(42)
goodwin <- function(u, p, t) {
  du1 <- p[[1]] / (2.15 + p[[3]] * u[[3]]^p[[4]]) - p[[2]] * u[[1]]
  du2 <- p[[5]] * u[[1]] - p[[6]] * u[[2]]
  du3 <- p[[7]] * u[[2]] - p[[8]] * u[[3]]
  list(du1, du2, du3)
}

noise_sd <- 0.05
npoints <- 100
p_star <- c(3.4884, 0.0969, 1, 10, 0.0969, 0.0581, 0.0969, 0.0775)
p0 <- c(3, 0.1, 4, 12, 0.1, 0.1, 0.1, 0.1)
u0 <- c(0.3617, 0.9137, 1.393)
t_span <- c(0, 80)

modelODE <- function(tvec, state, parameters) {
  list(as.vector(goodwin(state, parameters, tvec)))
}

t_eval <- seq(t_span[1], t_span[2], length.out = npoints)
sol <- deSolve::ode(
  y = u0,
  times = t_eval,
  func = modelODE,
  parms = p_star,
  method = "lsodes",
  atol = 1e-10,
  rtol = 1e-10
)

noise <- matrix(
  rnorm(nrow(sol) * (ncol(sol) - 1), mean = 0, sd = noise_sd),
  nrow = nrow(sol)
)
U <- sol[, -1] * exp(noise)
tt <- matrix(sol[, 1], ncol = 1)

p <- WendySolver(
  goodwin,
  U,
  p0,
  tt,
  noise_sd,
  compute_svd_ = TRUE,
  optimize_ = TRUE,
  dist_type_ = "LogNormal"
)

p_hat <- p$p_hat

sol_hat <- deSolve::ode(
  y = u0,
  times = t_eval,
  func = modelODE,
  parms = p_hat,
  method = "lsodes",
  atol = 1e-10,
  rtol = 1e-10
)[, -1]

plot(sol[, -1][, c(1, 3)], cex = 0.5)
points(sol_hat[, c(1, 3)], cex = 0.5, col = "red")

cat("pstar:", paste(p_star, collapse = " "), "\n")
cat(
  "phat:",
  paste(format(p_hat, digits = 3, scientific = FALSE), collapse = " "),
  "\n"
)

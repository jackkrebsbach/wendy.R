# %%
library(symengine)
library(deSolve)
library(plotly)
library(wendy)

# %%
sir_tdi <- function(u, p, t) {
  du1 <- -p[[1]] *
    u[[1]] +
    p[[3]] * u[[2]] +
    u[[3]] * (p[[1]] * exp(-p[[1]] * p[[2]])) / (1 - exp(-p[[1]] * p[[2]]))
  du2 <- p[[1]] *
    u[[1]] -
    p[[3]] * u[[2]] -
    p[[4]] * (1 - exp(-p[[5]] * t^2)) * u[[2]]
  du3 <- p[[4]] *
    (1 - exp(-p[[5]] * t^2)) *
    u[[2]] -
    (p[[1]] * exp(-p[[1]] * p[[2]]) / (1 - exp(-p[[1]] * p[[2]]))) * u[[3]]
  list(du1, du2, du3)
}

p_star <- c(1.99, 1.5, 0.074, 0.113, 0.0024)
p0 <- c(1, 1, 0.1, 0.1, 0.001)
u0 <- c(1, 0, 0)
t_span <- c(0, 50)
noise_sd <- 0.05
npoints <- 115

modelODE <- function(tvec, state, parameters) {
  list(as.vector(sir_tdi(state, parameters, tvec)))
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
# U <- sol[, -1] * exp(noise)
U <- sol[, -1] + noise
tt <- matrix(sol[, 1], ncol = 1)

p <- WendySolver(
  sir_tdi,
  U,
  p0,
  tt,
  noise_sd,
  compute_svd_ = TRUE,
  optimize_ = TRUE,
  # dist_type_ = "LogNormal"
)
p_hat <- p$p_hat

U_hat <- deSolve::ode(
  y = u0,
  times = t_eval,
  func = modelODE,
  parms = p_hat,
  method = "lsodes",
  atol = 1e-10,
  rtol = 1e-10
)[, -1]

fig3d <- plot_ly() |>
  add_trace(
    x = sol[, -1][, 1],
    y = sol[, -1][, 2],
    z = sol[, -1][, 3],
    type = 'scatter3d',
    mode = 'lines',
    name = 'True Trajectory'
  ) |>
  add_trace(
    x = U_hat[, 1],
    y = U_hat[, 2],
    z = U_hat[, 3],
    type = 'scatter3d',
    mode = 'lines',
    name = 'Estimated Trajectory',
    line = list(color = 'red', opacity = 0.95)
  ) |>
  add_trace(
    x = U[, 1],
    y = U[, 2],
    z = U[, 3],
    type = 'scatter3d',
    mode = 'markers',
    name = 'Noisy Data',
    marker = list(color = 'black', size = 2, opacity = 0.35)
  ) |>
  layout(
    paper_bgcolor = 'rgba(0,0,0,0)',
    plot_bgcolor = 'rgba(0,0,0,0)',
    legend = list(
      x = 0.02,
      y = 0.98,
      xanchor = "left",
      yanchor = "top"
    )
  )

fig3d

cat("pstar:", paste(p_star, collapse = " "), "\n")
cat(
  "phat:",
  paste(format(p_hat, digits = 3, scientific = FALSE), collapse = " "),
  "\n"
)

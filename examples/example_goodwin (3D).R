# %%
library(symengine)
library(deSolve)
library(plotly)
library(wendy)
library(tictoc)
# %%
tic()
set.seed(42)
goodwin <- function(u, p, t) {
  du1 <- p[[1]] / (2.15 + p[[3]] * u[[3]]^p[[4]]) - p[[2]] * u[[1]]
  du2 <- p[[5]] * u[[1]] - p[[6]] * u[[2]]
  du3 <- p[[7]] * u[[2]] - p[[8]] * u[[3]]
  list(du1, du2, du3)
}

noise_sd <- 0.05
npoints <- 256
p_star <- c(3.4884, 0.0969, 1, 10, 0.0969, 0.0581, 0.0969, 0.0775)
p0 <- c(3, 0.1, 4, 12, 0.1, 0.1, 0.1, 0.1)
u0 <- c(0.3617, 0.9137, 1.393)
t_span <- c(0, 80)

modelODE <- function(tvec, state, parameters) {
  list(as.vector(goodwin(state, parameters, tvec)))
}

t_eval <- seq(t_span[1], t_span[2], length.out = npoints)
sol <- deSolve::ode(y = u0, times = t_eval, func = modelODE, parms = p_star)

noise <- matrix(
  rnorm(nrow(sol) * (ncol(sol) - 1), mean = 0, sd = noise_sd),
  nrow = nrow(sol)
)
#U <- sol[, -1] * exp(noise)
U <- sol[, -1] + noise
tt <- matrix(sol[, 1], ncol = 1)

p <- WendySolver(goodwin, U, p0, tt, log_level = "info")

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
    name = 'Noisty Data',
    marker = list(color = 'black', size = 2, opacity = 0.35)
  ) |>
  layout(
    paper_bgcolor = 'rgba(0,0,0,0)', # Transparent outer background
    plot_bgcolor = 'rgba(0,0,0,0)', # Transparent plot area
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
toc()

# %%
library(magi)

MagiSolver(y, modelODE, control = list())

hes1modelODE <- function(theta, x, tvec) {
  P <- x[, 1]
  M <- x[, 2]
  H <- x[, 3]
  PMHdt <- array(0, c(nrow(x), ncol(x)))
  PMHdt[, 1] <- -theta[1] * P * H + theta[2] * M - theta[3] * P
  PMHdt[, 2] <- -theta[4] * M + theta[5] / (1 + P^2)
  PMHdt[, 3] <- -theta[1] * P * H + theta[6] / (1 + P^2) - theta[7] * H
  PMHdt
}

param.true <- list(
  theta = c(0.022, 0.3, 0.031, 0.028, 0.5, 20, 0.3),
  x0 = c(1.439, 2.037, 17.904),
  sigma = c(0.15, 0.15, NA)
)

modelODE <- function(tvec, state, parameters) {
  list(as.vector(hes1modelODE(parameters, t(state), tvec)))
}

x <- deSolve::ode(
  y = param.true$x0,
  times = seq(0, 60 * 4, by = 0.01),
  func = modelODE,
  parms = param.true$theta
)

set.seed(12321)
y <- as.data.frame(x[x[, "time"] %in% seq(0, 240, by = 7.5), ])
names(y) <- c("time", "P", "M", "H")
y$P <- y$P * exp(rnorm(nrow(y), sd = param.true$sigma[1]))
y$M <- y$M * exp(rnorm(nrow(y), sd = param.true$sigma[2]))


y$H <- NaN
y$P[y$time %in% seq(7.5, 240, by = 15)] <- NaN
y$M[y$time %in% seq(0, 240, by = 15)] <- NaN


compnames <- c("P", "M", "H")
matplot(
  x[, "time"],
  x[, -1],
  type = "l",
  lty = 1,
  xlab = "Time (min)",
  ylab = "Level"
)
matplot(
  y$time,
  y[, -1],
  type = "p",
  col = 1:(ncol(y) - 1),
  pch = 20,
  add = TRUE
)
legend("topright", compnames, lty = 1, col = c("black", "red", "green"))

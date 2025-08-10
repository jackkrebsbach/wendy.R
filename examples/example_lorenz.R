# %%
library(wendy)
library(symengine)
library(deSolve)
library(plotly)
# %%
lorenz <- function(u, p, t) {
    du1 <- p[[1]] * (u[[2]] - u[[1]])
    du2 <- u[[1]] * (p[[2]] - u[[3]]) - u[[2]]
    du3 <- u[[1]] * u[[2]] - p[[3]] * u[[3]]
    list(du1, du2, du3)
}

noise_sd <- 0.05
p_star <- c(10.0, 28.0, 4.0)
p0 <- c(13.10, 21, 4.0)
u0 <- c(2, 1, 1)

npoints <- 200
t_span <- c(0, 10)
t_eval <- seq(t_span[1], t_span[2], length.out = npoints)

modelODE_ <- function(tvec, state, parameters) {
    list(as.vector(lorenz(state, parameters, tvec)))
}

sol <- deSolve::ode(
    y = u0,
    times = t_eval,
    func = modelODE_,
    parms = p_star,
    method = "lsodes",
    atol = 1e-10,
    rtol = 1e-10
)

# Additive Guassian
noise <- matrix(
    rnorm(nrow(sol) * (ncol(sol) - 1), mean = 0, sd = noise_sd),
    nrow = nrow(sol)
)
U <- sol[, -1] + noise

tt <- matrix(sol[, 1], ncol = 1)

res <- WendySolver(
    lorenz,
    U,
    p0,
    tt,
    noise_sd,
    compute_svd_ = TRUE,
    optimize_ = TRUE,
    dist_type = "AddGaussian"
)

p_hat <- res$p_hat

sol_hat <- deSolve::ode(
    u0,
    t_eval,
    modelODE_,
    p_hat,
    method = "lsodes",
    atol = 1e-10,
    rtol = 1e-10
)[, -1]

# plot(U[, c(1, 2)], cex = 0.5, col = "blue")
# points(sol_hat[, c(1, 2)], cex = 0.5, col = "red")
plot_ly(
    x = U[, 1],
    y = U[, 2],
    type = 'scatter',
    mode = 'markers',
    marker = list(color = 'blue', size = 3),
    name = "data"
) |>
    add_trace(
        x = sol_hat[, 1],
        y = sol_hat[, 2],
        type = 'scatter',
        mode = 'markers',
        marker = list(color = 'red', size = 3),
        name = "fit"
    )

cat("pstar:", paste(p_star, collapse = " "), "\n")
cat(
    "phat:",
    paste(format(p_hat), collapse = " "),
    "\n"
)

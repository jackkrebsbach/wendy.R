library(symengine)

goodwin_3d <- function(u, p) {
  u1 <- u[1]
  u2 <- u[2]
  u3 <- u[3]
  p1 <- p[1]
  p2 <- p[2]
  p3 <- p[3]
  p4 <- p[4]
  p5 <- p[5]
  p6 <- p[6]
  p7 <- p[7]
  p8 <- p[8]
  
  du1dt <- p1 / (2.15 + p3 * u3^p4) - p2 * u1
  du2dt <- p5 * u1 - p6 * u2
  du3dt <- p7 * u2 - p8 * u3
  
  c(du1dt, du2dt, du3dt)
}

npoints <- 500
t_span <- c(0, 20)
t_eval <- seq(t_span[1], t_span[2], length.out = npoints)
dt <- t_eval[2] - t_eval[1]
u0 <- c(7, -10, 5)
p_star <- c(72, 1, 2, 1, 1, 1, 1, 1)

u_mat <- matrix(NA, nrow = npoints, ncol = 3)
u_mat[1, ] <- u0

for (i in 2:npoints) {
  u_mat[i, ] <- u_mat[i - 1, ] + dt * goodwin_3d(u_mat[i - 1, ], p_star)
}

u1_star <- u_mat[, 1]
u2_star <- u_mat[, 2]
u3_star <- u_mat[, 3]

noise_ratio <- 0.05

set.seed(42) 

e1 <- rnorm(npoints, mean = 0, sd = sqrt(noise_ratio * var(u1_star)))
e2 <- rnorm(npoints, mean = 0, sd = sqrt(noise_ratio * var(u2_star)))
e3 <- rnorm(npoints, mean = 0, sd = sqrt(noise_ratio * var(u3_star)))

u1 <- u1_star + e1
u2 <- u2_star + e2
u3 <- u3_star + e3


f <- function(u, p, t) {
  du1 <- p[[1]] / (2.15 + p[[3]] * u[[3]]^p[[4]]) - p[[2]] * u[[1]]
  du2 <- p[[5]] * u[[1]] - p[[6]] * u[[2]]
  du3 <- p[[7]] * u[[2]] - p[[8]] * u[[3]]
  list(du1, du2, du3)
}

p_hat <- as.numeric(p_star)
U <- matrix(c(u1, u2, u3), ncol = 3)
tt <- t_eval

u <- lapply(1:ncol(U), function(i) S(paste0("u", i)))
p <- lapply(1:length(p_hat), function(i) S(paste0("p", i)))
t <- S("t")

du <- f(u, p, t) |>
  vapply(as.character, character(1))


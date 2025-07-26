library(symengine)
library(deSolve)

set.seed(42)

unlink(tempdir(), recursive = TRUE)

Sys.setenv("PKG_CXXFLAGS" = paste(
    paste0(Rcpp:::CxxFlags()),
  "-std=c++20",
  "-I/opt/homebrew/include",
  "-I/opt/homebrew/include/Eigen3",
  "-I/Users/krebsbach/ml/wendy/src/core/external/CppNumericalSolvers/include",
  "-I/Users/krebsbach/ml/wendy/src/core/external/exprtk/include",
  "-I/opt/homebrew/Caskroom/miniforge/base/include"
))

Sys.setenv("PKG_LIBS" = paste(
  paste0(Rcpp:::LdFlags()),
  "-L/opt/homebrew/lib",
  "-L/opt/homebrew/Caskroom/miniforge/base/",
  "-lsymengine -lflint -lgmp -lmpfr -lfmt -lfftw3"
))

Rcpp::sourceCpp('exploration/pkg-dev.cpp')

logistic <- function(u, p, t) {
  list(p[[1]] * u[[1]] - p[[2]] * u[[1]]^2)
}

u0 <- c(0.01)
p0 <- c(0.5, 0.5)
p_star <- c(1, 1)

npoints <- 100
t_span <- c(0, 10)
t_eval <- seq(t_span[1], t_span[2], length.out = npoints)

modelODE <- function(tvec, state, parameters) {
   list(as.vector(logistic(state, parameters, tvec)))
}

sol <- deSolve::ode(
  y = u0,
  times = t_eval,
  func = modelODE,
  parms = p_star
)

u1_star <- sol[,2]

noise_ratio <- 0.05

e1 <- noise_ratio * rnorm(npoints)
u1 <- u1_star + e1
U <- matrix(c(u1), ncol = 1)
tt <- matrix(sol[,1], ncol = 1)

u <- lapply(1:ncol(U), function(i) symengine::S(paste0("u", i)))
p <- lapply(1:length(p0), function(i) symengine::S(paste0("p", i)))
t <- symengine::S("t")

du <- logistic(u, p, t) |>
  vapply(as.character, character(1))

plot(U, cex = 0.5) 


Rcpp::sourceCpp('exploration/pkg-dev.cpp')
data <- WendySolver(du, U, p0, tt, compute_svd_ = TRUE)

plot(data$min_radius_radii, data$min_radius_errors)

p_hat <- data$p_hat
V <- data$V
V_prime <- data$V_prime

sol2 <- deSolve::ode(
  y = u0,
  times = t_eval,
  func = modelODE,
  parms = p_hat
)

plot(sol)
plot(sol2)

p_hat

unlink(tempdir(), recursive = TRUE)

Sys.setenv(
  "PKG_CXXFLAGS" = paste(
    paste0(Rcpp:::CxxFlags()),
    "-std=c++20",
    "-O3",
    "-march=native",
    "-ffast-math",
    "-funroll-loops",
    "-flto",
    "-fstrict-aliasing",
    "-DNDEBUG",
    "-I/opt/homebrew/include",
    "-I/opt/homebrew/include/Eigen3",
    "-I/Users/krebsbach/ml/wendy/src/core/external/CppNumericalSolvers/include",
    "-I/Users/krebsbach/ml/wendy/src/core/external/exprtk/include",
    "-I/opt/homebrew/Caskroom/miniforge/base/include"
  )
)

Sys.setenv(
  "PKG_LIBS" = paste(
    paste0(Rcpp:::LdFlags()),
    "-L/opt/homebrew/lib",
    "-L/opt/homebrew/Caskroom/miniforge/base/",
    "-lsymengine -lflint -lgmp -lmpfr -lfmt -lfftw3 -lceres"
  )
)


Rcpp::sourceCpp('src/main.cpp')

DistType <- c("AddGaussian", "LogNormal")

validate_dist_type <- function(x) {
  match.arg(x, DistType)
}

WendySolver <- function(
  f,
  U,
  p0,
  tt,
  noise_sd = 0.05,
  compute_svd_ = TRUE,
  optimize_ = TRUE,
  dist_type_ = "AddGaussian"
) {
  if (length(tt) != nrow(U)) {
    stop(sprintf(
      "Length of tt (%d) must match number of rows in U (%d)",
      length(tt),
      nrow(U)
    ))
  }
  u <- lapply(1:ncol(U), function(i) symengine::S(paste0("u", i)))
  p <- lapply(1:length(p0), function(i) symengine::S(paste0("p", i)))
  t <- symengine::S("t")

  du <- f(u, p, t) |>
    vapply(as.character, character(1))

  data <- SolveWendyProblem(
    du,
    U,
    p0,
    tt,
    noise_sd,
    compute_svd_,
    optimize_,
    dist_type = dist_type_
  )

  data$plot_radius_selection <- function() {
    errors <- log(data$min_radius_errors)
    radii <- data$min_radius_radii
    ix <- data$min_radius_ix

    plot(
      radii,
      errors,
      type = "b",
      col = "blue",
      pch = 16,
      xlab = "Radius",
      ylab = "log(Error)",
      main = "Radius Selection: Error vs Radius"
    )

    axis(1, at = pretty(radii, n = 10))
    abline(v = radii[ix + 1], col = "red", lwd = 2, lty = 2)
    legend("topright", legend = "min_radius", col = "red", lwd = 2, lty = 2)
  }

  return(data)
}

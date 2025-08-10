#' Estimate parameters using WENDy
#'
#' @param f A symbolic function.
#' @param U Observed data matrix.
#' @param p0 Initial parameter guess.
#' @param tt Time vector.
#' @param noise_sd Standard deviation of noise.
#' @param solver Use ceres general optimization or ipopt.
#' @param compute_svd_ Whether to compute the SVD.
#' @param optimize_ Whether to optimize the objective.
#' @param dist_type_ Distribution type ("AddGaussian" or "LogNormal").
#' @return A list with estimation results.
#' @export
WendySolver <- function(
  f,
  U,
  p0,
  tt,
  noise_sd = 0.05,
  solver = "ipopt",
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
  DistType <- c("AddGaussian", "LogNormal")

  validate_dist_type <- function(x) {
    match.arg(x, DistType)
  }

  u <- lapply(1:ncol(U), function(i) symengine::S(paste0("u", i)))
  p <- lapply(1:length(p0), function(i) symengine::S(paste0("p", i)))
  t <- symengine::S("t")

  du <- vapply(f(u, p, t), as.character, character(1))

  data <- SolveWendyProblem(
    du,
    U,
    p0,
    tt,
    noise_sd,
    solver,
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

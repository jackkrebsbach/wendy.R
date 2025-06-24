.onLoad <- function(libname, pkgname) {
  if (!requireNamespace("symengine", quietly = TRUE)) {
    stop("The 'symengine' package is required but not installed. Please install it with install.packages('symengine').")
  }
  Rcpp::loadModule("WendyR", TRUE)
}

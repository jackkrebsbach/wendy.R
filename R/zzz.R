.onLoad <- function(libname, pkgname) {
  Rcpp::loadModule("WendyR", TRUE)
}

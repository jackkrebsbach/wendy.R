#' Load the WENDy Rcpp module
#' @export
load_wendy_module <- function() {
  loadModule("WENDy", TRUE)
  invisible(NULL)
}

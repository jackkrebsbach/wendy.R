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


Rcpp::sourceCpp('src/main.cpp')


WendySolver <- function(f, U, p0, tt, compute_svd_ = TRUE, optimize_ = TRUE){
  
  u <- lapply(1:ncol(U), function(i) symengine::S(paste0("u", i)))
  p <- lapply(1:length(p0), function(i) symengine::S(paste0("p", i)))
  t <- symengine::S("t")

  du <- f(u, p, t) |>
    vapply(as.character, character(1))

    return(SolveWendyProblem(du, U, p0, tt, compute_svd_, optimize_))

}
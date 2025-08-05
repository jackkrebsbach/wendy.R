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

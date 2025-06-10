
#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector makeSymbolicSystem(NumericMatrix U, Function func,
                                 NumericVector p) {

  // J Number of parameters
  // D Dimension of the system
  int const J = p.length();
  int const D = U.cols();
}
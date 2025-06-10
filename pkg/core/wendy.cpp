#include "wendy.h"
#include "symbolic_utils.h"
#include <Rcpp.h>
#include <symengine/expression.h>

Wendy::Wendy(Rcpp::CharacterVector du, NumericMatrix U, NumericVector params) {
  J = params.length();
  D = U.cols();
  sym_system = create_symbolic_system(du, D, J);
}
#include "./core/core.h"
#include <Rcpp.h>
#include <symengine/expression.h>

// [[Rcpp::export]]
Rcpp::String getSymbolicExpression() {
  auto ex = makeSymbolicExpression();
  std::ostringstream oss;
  oss << ex;

  return Rcpp::String(oss.str());
}
#include <Rcpp.h>
#include <symengine/expression.h>
#include <symengine/parser.h>

using namespace Rcpp;
using namespace SymEngine;

// [[Rcpp::export]]
Rcpp::String process_symbolic_dx(CharacterVector dx_chr) {
  std::vector<Expression> dx(dx_chr.size());
  for (int i = 0; i < dx_chr.size(); ++i) {
    dx[i] = SymEngine::parse(Rcpp::as<std::string>(dx_chr[i]));
  }
  std::ostringstream oss;
  for (size_t i = 0; i < dx.size(); ++i) {
    oss << dx[i];
    if (i != dx.size() - 1)
      oss << ", ";
  }
  return Rcpp::String(oss.str());
}

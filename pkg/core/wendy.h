#ifndef WENDY_H
#define WENDY_H

#include <Rcpp.h>
#include <symengine/expression.h>
#include <symengine/lambda_double.h>

using namespace Rcpp;

class Wendy {
public:
  int D;
  int J;
  double min_radius;
  std::vector<SymEngine::Expression> sym_system;
  std::vector<std::vector<SymEngine::Expression>> sym_system_jac;

  Wendy(CharacterVector f, NumericMatrix U, NumericVector params);
};

#endif

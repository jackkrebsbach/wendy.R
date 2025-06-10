#ifndef WENDY_H
#define WENDY_H

#include <Rcpp.h>
#include <symengine/expression.h>
#include <symengine/lambda_double.h>

using namespace Rcpp;

class Wendy {
public:
  std::vector<SymEngine::LambdaRealDoubleVisitor> sym_system;
  int D;
  int J;
  double min_radius;
  Wendy(CharacterVector du, NumericMatrix U, NumericVector params);
};

#endif

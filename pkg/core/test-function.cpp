
#include <algorithm>
#include <cmath>
#include <symengine/expression.h>
#include <symengine/lambda_double.h>

using namespace SymEngine;

double MIN_CONST = 0.0001;

double phi(double t, double a, double eta = 9) {
  return (std::exp(-eta / std::max(1 - std::pow((t / a), 2), MIN_CONST)));
}

double phi2(double X, double Y) {

  RCP<const Symbol> x = symbol("x");
  RCP<const Symbol> y = symbol("y");

  RCP<const Basic> expr = add(sin(x), mul(integer(2), y)); // sin(x) + 2*y

  SymEngine::LambdaRealDoubleVisitor visitor;
  visitor.init({x, y}, *expr);

  double result = visitor.call({X, Y});

  return result;
}
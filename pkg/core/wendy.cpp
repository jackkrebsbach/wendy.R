#include "wendy.h"
#include <symengine/expression.h>

using SymEngine::Expression;

Expression makeSymbolicExpression() {
  Expression x("x");
  auto ex = pow(x + sqrt(Expression(3)), 6);
  return ex;
}
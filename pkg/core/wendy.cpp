#include "wendy.h"

using SymEngine::Expression;

Expression Wendy::makeSymbolicExpression() {
  Expression x("x");
  auto ex = pow(x + sqrt(Expression(3)), 6);
  return ex;
}

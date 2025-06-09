#include <iostream>
#include <symengine/expression.h>

using SymEngine::Expression;

int main() {
  Expression x("x");
  auto ex = pow(x + sqrt(Expression(2)), 6);
  Expression expanded_ex = expand(ex);
  std::cout << expanded_ex << std::endl;
  return 0;
}
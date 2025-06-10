#ifndef WENDY_H
#define WENDY_H

#include <symengine/expression.h>

class Wendy {
public:
  int system;
  int time_steps;

  SymEngine::Expression makeSymbolicExpression();
};

#endif

#include "symbolic_utils.h"
#include "Rcpp/vector/instantiation.h"
#include <Rcpp.h>
#include <symengine/expression.h>
#include <symengine/lambda_double.h>
#include <symengine/parser.h>

using namespace Rcpp;
using namespace SymEngine;

std::vector<Expression> create_symbolic_vars(const std::string &base_name,
                                             int count) {
  std::vector<Expression> vars;
  for (int i = 0; i < count; i++) {
    vars.push_back(Expression(symbol(base_name + std::to_string(i + 1))));
  }
  return vars;
}

vec_basic build_input_symbols(const std::vector<Expression> &u,
                              const std::vector<Expression> &p,
                              const Expression &t) {
  vec_basic inputs;
  for (const auto &e : u)
    inputs.push_back(e.get_basic());
  for (const auto &e : p)
    inputs.push_back(e.get_basic());
  inputs.push_back(t.get_basic());
  return inputs;
}

std::vector<LambdaRealDoubleVisitor> create_symbolic_system(CharacterVector du,
                                                            int D, int J) {
  auto u = create_symbolic_vars("u", D);
  auto p = create_symbolic_vars("p", J);
  auto t = Expression(symbol("t"));

  std::vector<Expression> dx(du.size());
  for (int i = 0; i < du.size(); ++i) {
    dx[i] = SymEngine::parse(Rcpp::as<std::string>(du[i]));
  }

  vec_basic inputs = build_input_symbols(u, p, t);

  std::vector<LambdaRealDoubleVisitor> visitors;
  visitors.reserve(dx.size());

  for (int i = 0; i < dx.size(); ++i) {
    LambdaRealDoubleVisitor visitor;
    visitor.init(inputs, *dx[i].get_basic());
    visitors.push_back(std::move(visitor));
  }

  return visitors;
}
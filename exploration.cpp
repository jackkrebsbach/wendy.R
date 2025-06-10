#include <Rcpp.h>
#include <symengine/expression.h>
using namespace Rcpp;
using namespace SymEngine;
using SymEngine::exp;
using SymEngine::Expression;
using SymEngine::map_basic_basic;
using SymEngine::symbol;

std::vector<Expression> create_symbolic_vars(const std::string &base_name,
                                             int count) {
  std::vector<Expression> vars;
  for (int i = 0; i < count; i++) {
    vars.push_back(Expression(symbol(base_name + std::to_string(i + 1))));
  }
  return vars;
}

template <typename Vec, typename ParamVec, typename TimeVar>
void goodwin_2d(Vec &du, const Vec &u, const ParamVec &p, TimeVar &t) {
  auto u1 = u[0];
  auto u2 = u[1];
  du[0] = p[0] - p[2] / (36.0 + p[1] * u2);
  du[1] = p[3] * u1 - p[4];
}

// [[Rcpp::export]]
Rcpp::String makeSymbolicSystem(NumericMatrix U, NumericVector p_hat) {

  int const J = p_hat.length(); // J Number of parameters
  int const D = U.cols();       // D Dimension of the system

  // Symbolic Expressions
  auto x = create_symbolic_vars("x", D); // State variables
  auto p = create_symbolic_vars("p", J); // Parameters
  auto t = Expression(symbol("t"));
  std::vector<Expression> dx(D);

  goodwin_2d(dx, x, p, t);

  map_basic_basic statemap;
  for (int i = 0; i < D; ++i) {
    statemap[x[i].get_basic()] = exp(x[i]);
  }

  std::vector<Expression> result;
  for (int i = 0; i < D; ++i) {
    Expression fu = dx[i] / x[i];
    Expression substituted = fu.subs(statemap);
    result.push_back(substituted);
  }

  std::ostringstream oss;
  oss << "[";
  for (size_t i = 0; i < result.size(); ++i) {
    oss << result[i];
    if (i != result.size() - 1) {
      oss << ", ";
    }
  }
  oss << "]";

  return Rcpp::String(oss.str());
}
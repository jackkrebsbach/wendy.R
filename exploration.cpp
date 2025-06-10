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

// [[Rcpp::export]]
NumericVector symbolicSystemEval(CharacterVector du, NumericMatrix U,
                                 NumericVector u_eval, double t_eval,
                                 NumericVector p_hat) {
  int const J = p_hat.length(); // J Number of parameters
  int const D = U.cols();       // D Dimension of the system

  // Symbolic Expressions
  auto u = create_symbolic_vars("u", D);
  auto p = create_symbolic_vars("p", J);
  auto t = Expression(symbol("t"));

  std::vector<Expression> dx(du.size());

  for (int i = 0; i < du.size(); ++i) {
    dx[i] = SymEngine::parse(Rcpp::as<std::string>(du[i]));
  }

  std::vector<double> visitors(dx.size());

  std::vector<double> input_values;
  input_values.insert(input_values.end(), u_eval.begin(),
                      u_eval.end()); // u1, u2
  input_values.insert(input_values.end(), p_hat.begin(),
                      p_hat.end()); // p1 ... p5
  input_values.push_back(t_eval);   // t

  vec_basic inputs = build_input_symbols(u, p, t);

  for (int i = 0; i < du.size(); ++i) {
    auto expr = dx[i];
    SymEngine::LambdaRealDoubleVisitor visitor;
    // For debugging
    //  Rcpp::Rcout << "Expression " << i << ": " << dx[i] << "\n";
    //  Rcpp::Rcout << "Input symbols: ";
    //  for (const auto &sym : inputs) {
    //    Rcpp::Rcout << *sym << " ";
    //  }
    // Rcpp::Rcout << "\n";

    visitor.init(inputs, *expr.get_basic());
    visitors[i] = visitor.call(input_values);
  }

  return Rcpp::wrap(visitors);
}

Rcpp::CharacterVector symbolic_derivative(Rcpp::CharacterVector exprs_chr) {
  using namespace SymEngine;
  Rcpp::CharacterVector results(exprs_chr.size());
  RCP<const SymEngine::Symbol> p = symbol("p"); // Differentiate w.r.t. p

  for (int i = 0; i < exprs_chr.size(); ++i) {
    RCP<const Basic> expr = parse(Rcpp::as<std::string>(exprs_chr[i]));
    RCP<const Basic> dexpr = expr->diff(p);
    std::ostringstream oss;
    oss << *dexpr;
    results[i] = oss.str();
  }
  return results;
}
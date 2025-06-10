#ifndef SYMBOLIC_UTILS_H
#define SYMBOLIC_UTILS_H

#include <Rcpp.h>
#include <symengine/expression.h>
#include <symengine/lambda_double.h>

using namespace Rcpp;
using namespace SymEngine;

std::vector<Expression> create_symbolic_system(CharacterVector f, int D, int J);

std::vector<Expression> create_symbolic_vars(const std::string &base_name,
                                             int count);

std::vector<SymEngine::Expression> create_all_symbolic_inputs(int J, int D);

std::vector<std::vector<Expression>>
compute_jacobian(const std::vector<Expression> &system,
                 const std::vector<Expression> &inputs);

#endif
#ifndef SYMBOLIC_UTILS_H
#define SYMBOLIC_UTILS_H

#include <Rcpp.h>
#include <symengine/expression.h>
#include <symengine/lambda_double.h>

using namespace Rcpp;
using namespace SymEngine;

std::vector<LambdaRealDoubleVisitor> create_symbolic_system(CharacterVector du,
                                                            int D, int J);

std::vector<Expression> create_symbolic_vars(const std::string &base_name,
                                             int count);

vec_basic build_input_symbols(const std::vector<Expression> &u,
                              const std::vector<Expression> &p,
                              const Expression &t);

#endif
#include "wendy.h"
#include "symbolic_utils.h"
#include <Rcpp.h>
#include <symengine/expression.h>

// Constructor
Wendy::Wendy(Rcpp::CharacterVector du, NumericMatrix U, NumericVector params) {

  J = params.length(); // Number of parameters p1, ...
  D = U.cols();        // Dimension of the system

  // Symbolic representation of the D dimensional system f
  sym_system = create_symbolic_system(du, D, J);

  // All inputs including parameters p1,... and the state variables u1,... and t
  std::vector<SymEngine::Expression> sym_inputs = create_symbolic_inputs(J, D);

  // Symbolic representation of the jacobian of the system f
  sym_system_jac = compute_jacobian(sym_system, sym_inputs);
}
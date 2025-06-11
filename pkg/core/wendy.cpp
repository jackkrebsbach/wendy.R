#include "wendy.h"
#include "symbolic_utils.h"
#include <Rcpp.h>
#include <symengine/expression.h>

// Constructor
Wendy::Wendy(Rcpp::CharacterVector f, NumericMatrix U, NumericVector p0) {

  J = p0.length(); // Number of parameters p1, ...
  D = U.cols();    // Dimension of the system

  // Symbolic representation of the D dimensional system f
  sym_system = create_symbolic_system(f);

  // Symbolic representation of the jacobian of the system f
  // We want the Jacobian with respect to the input parameters p1, ...
  sym_system_jac = compute_jacobian(sym_system, create_symbolic_vars("p", J));
}
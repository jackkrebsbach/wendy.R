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

  // Symbolic representation of the jacobian of the system f and hessian w.r.t
  // p, u, pp, up, pu grad_p f
  auto p_symbols = create_symbolic_vars("p", J);
  auto u_symbols = create_symbolic_vars("u", D);

  // Jacobian of the system grad_p f
  auto grad_p_f = compute_jacobian(sym_system, p_symbols);
  // Jacobian of the system grad_u f
  auto grad_u_f = compute_jacobian(sym_system, u_symbols);
  // Hessian of the system grad_pp f
  auto grad_pp_f = compute_jacobian(grad_p_f, p_symbols);
  // Hessian grad_up f
  auto grad_up_f = compute_jacobian(grad_u_f, p_symbols);
  // Hessian grad_pu f
  auto grad_pu_f = compute_jacobian(grad_p_f, u_symbols);

  sym_system_jac = grad_p_f;
};
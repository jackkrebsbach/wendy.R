#include <Rcpp.h>

#include "./core/wendy.h"

using namespace Rcpp;

RCPP_MODULE(WENDy) {
  class_<Wendy>("WENDy")
      .constructor<CharacterVector, NumericMatrix, NumericVector>()
      .field("D", &Wendy::D)
      .field("J", &Wendy::J)
      .field("min_radius", &Wendy::min_radius)
      .method("log_details", &Wendy::log_details);
}
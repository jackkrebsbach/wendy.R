#include "../src/core/src/wendy.h"
#include <Rcpp.h>

static xt::xarray<double> as_xtarray(const Rcpp::NumericMatrix &mat)
{
  std::vector<size_t> shape = {static_cast<size_t>(mat.nrow()),
                               static_cast<size_t>(mat.ncol())};
  return xt::adapt(mat.begin(), mat.size(), xt::no_ownership(), shape);
}

static std::vector<double> as_double_vector(const Rcpp::NumericVector &v)
{
  std::vector<double> out(v.size());
  for (R_xlen_t i = 0; i < v.size(); ++i)
    out[i] = v[i];
  return out;
}

// Convert xt::xarray<double> (2D) to Rcpp::NumericMatrix
static Rcpp::NumericMatrix as_numeric_matrix(const xt::xarray<double>& arr)
{
    if (arr.dimension() != 2) {
        Rcpp::stop("Input xt::xarray<double> is not 2-dimensional.");
    }
    size_t nrow = arr.shape()[0];
    size_t ncol = arr.shape()[1];
    Rcpp::NumericMatrix mat(nrow, ncol);

    for (size_t j = 0; j < ncol; ++j) {
        for (size_t i = 0; i < nrow; ++i) {
            mat(i, j) = arr(i, j);
        }
    }
    return mat;
}

// Convert std::vector<double> to Rcpp::NumericVector
static Rcpp::NumericVector as_numeric_vector(const std::vector<double>& v)
{
    return Rcpp::NumericVector(v.begin(), v.end());
}

// Overload for xt::xtensor<double, 1>
static Rcpp::NumericVector as_numeric_vector(const xt::xtensor<double, 1>& arr)
{
    return Rcpp::NumericVector(arr.data(), arr.data() + arr.size());
}


// [[Rcpp::export]]
Rcpp::List SolveWendyProblem(Rcpp::CharacterVector f, Rcpp::NumericMatrix U, Rcpp::NumericVector p0, Rcpp::NumericMatrix tt, bool compute_svd_)
{

  const auto w = new Wendy(Rcpp::as<std::vector<std::string>>(f), as_xtarray(U), as_double_vector(p0), as_xtarray(tt), compute_svd_);

  w->build_full_test_function_matrices();
  w->build_objective_function();
  

  return Rcpp::List::create(
      Rcpp::Named("p_hat")   = Rcpp::wrap(as_numeric_vector(w->p_hat)),
      Rcpp::Named("V")       = Rcpp::wrap(as_numeric_matrix(w->V)),
      Rcpp::Named("V_prime") = Rcpp::wrap(as_numeric_matrix(w->V_prime)),
      Rcpp::Named("min_radius_errors") = Rcpp::wrap(as_numeric_vector(w->min_radius_errors)),
      Rcpp::Named("min_radius_radii") = Rcpp::wrap(as_numeric_vector(w->min_radius_radii)),
      Rcpp::Named("min_radius_ix") = Rcpp::wrap(w->min_radius_ix),
      Rcpp::Named("min_radius") = Rcpp::wrap(w->min_radius)
  );
}
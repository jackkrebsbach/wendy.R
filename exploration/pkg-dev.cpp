#include "../src/core/src/wendy.h"
#include <Rcpp.h>
#include <xtensor/containers/xadapt.hpp>
#include <xtensor/containers/xarray.hpp>
#include <xtensor/views/xview.hpp>

#include <string>
#include <vector>

class WendyRDev : public Wendy {
public:
  WendyRDev(Rcpp::CharacterVector f, Rcpp::NumericMatrix U,
            Rcpp::NumericVector p0, Rcpp::NumericMatrix tt)
      : Wendy(Rcpp::as<std::vector<std::string>>(f), as_xtarray(U),
              as_float_vector(p0), as_xtarray(tt)) {}
  size_t getD() const { return D; }
  size_t getJ() const { return J; }

  Rcpp::NumericMatrix getV() const {
    auto shape = V.shape();
    Rcpp::NumericMatrix mat(shape[0], shape[1]);

    for (size_t i = 0; i < shape[0]; ++i)
      for (size_t j = 0; j < shape[1]; ++j)
        mat(i, j) = V(i, j);
    return mat;
  }

  void log_details() const { Wendy::log_details(); }
  void build_full_test_function_matrices() {
    Wendy::build_full_test_function_matrices();
  }

  static xt::xarray<double> as_xtarray(const Rcpp::NumericMatrix &mat) {
    std::vector<size_t> shape = {static_cast<size_t>(mat.nrow()),
                                 static_cast<size_t>(mat.ncol())};
    return xt::adapt(mat.begin(), mat.size(), xt::no_ownership(), shape);
  }

  static std::vector<float> as_float_vector(const Rcpp::NumericVector &v) {
    std::vector<float> out(v.size());
    for (R_xlen_t i = 0; i < v.size(); ++i)
      out[i] = static_cast<float>(v[i]);
    return out;
  }
};

RCPP_MODULE(WendyRDev) {
  using namespace Rcpp;
  class_<WendyRDev>("WendyRDev")
      .constructor<CharacterVector, NumericMatrix, NumericVector,
                   NumericMatrix>()
      .method("getD", &WendyRDev::getD)
      .method("getJ", &WendyRDev::getJ)
      .method("log_details", &WendyRDev::log_details)
      .method("getV", &WendyRDev::getV)
      .method("build_full_test_function_matrices",
              &WendyRDev::build_full_test_function_matrices);
}

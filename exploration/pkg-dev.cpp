
#pragma once
#include "../src/core/src/wendy.h"
#include <Rcpp.h>
#include <xtensor/xarray.hpp>
#include <xtensor/xtensor.hpp>
#include <xtensor/xadapt.hpp>
#include <vector>
#include <string>

class WendyR : public Wendy {
public:
    WendyR(Rcpp::CharacterVector f, Rcpp::NumericMatrix U, Rcpp::NumericVector p0)
        : Wendy(
            Rcpp::as<std::vector<std::string>>(f),
            as_xtarray(U),
            as_float_vector(p0)
        )
    {}

    static xt::xarray<double> as_xtarray(const Rcpp::NumericMatrix& mat) {
        std::vector<size_t> shape = {static_cast<size_t>(mat.nrow()), static_cast<size_t>(mat.ncol())};
        return xt::adapt(mat.begin(), mat.size(), xt::no_ownership(), shape);
    }

    static std::vector<float> as_float_vector(const Rcpp::NumericVector& v) {
        std::vector<float> out(v.size());
        for (R_xlen_t i = 0; i < v.size(); ++i) out[i] = static_cast<float>(v[i]);
        return out;
    }
};


RCPP_MODULE(WENDy) {
    class_<WendyR>("WendyR")
        .constructor<CharacterVector, NumericMatrix, NumericVector>()
        .field("D", &Wendy::D)
        .field("J", &Wendy::J)
        .field("min_radius", &Wendy::min_radius)
        .method("log_details", &Wendy::log_details);
}
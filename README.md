# WENDy 

Weak Form Estimation of Nonlinear Dynamics (WENDy) is an algorithm to estimate parameters of a system of Ordinary Differential Equations (ODE).


# Development

## Dependencies

The core code of WENDy is implemented in c++ and wrapped by Rcpp. If and when a Python module is desired then we will potentially use [Boost.Python](https://www.boost.org/doc/libs/1_88_0/libs/python/doc/html/index.html). To contribute the following c++ packages must be installed.

- [SymEngine](https://github.com/symengine/symengine) for symbolic differentation.


# WENDy

> \[!WARNING\] This package is not ready for production usage and is still under development.

Weak Form Estimation of Nonlinear Dynamics (WENDy) is an algorithm to estimate parameters of a system of Ordinary Differential Equations (ODE).

## Dependencies

This package requires the following C++ libraries:

-   **SymEngine**
-   **FFTW**
-   **Ceres Solver**

You can install these dependencies using either Conda or Homebrew, depending on your platform.

### Install with Homebrew (macOS)

``` bash
brew install symengine fftw ceres-solver ipopt
```

### Install with Conda

``` bash
conda install -c conda-forge symengine fftw ceres-solver ipopt
```

**Note:**\
Make sure to activate your Conda environment before installing or using this package if you choose the Conda method. Run 

``` bash
conda env list
```

to find the conda prefix where the system dependencies live. 

In R, before installation, run

``` r
Sys.setenv(WENDY_USE_CONDA = "1")
Sys.setenv(CONDA_PREFIX = "{YOUR CONDA PREFIX}")
```

Install R dependencies

```r
install.packages(c("symengine", "deSolve"))
```

## Installation

``` r
devtools::install_github("jackkrebsbach/wendy.R")
```

or

``` r
remotes::install_github("jackkrebsbach/wendy.R")
```

## Examples

-   [Logistic](examples/example_logistic.R)
-   [Lorenz](examples/example_lorenz.R)
-   [Goodwin(2D)](examples/example_goodwin%20(2D).R)
-   [Goodwin(3D)](examples/example_goodwin%20(3D).R)
.onLoad <- function(libname, pkgname) {
  sofile <- system.file("libs", .Platform$r_arch, "wendy.so", package = pkgname)
  if (sofile == "") {
    sofile <- system.file("libs", "wendy.so", package = pkgname)
  }
  tryCatch(
    dyn.load(sofile),
    error = function(e) {
      msg <- paste(
        "Unable to load the SymEngine C++ library required by the wendy package.\n",
        "This usually means the SymEngine shared library (libsymengine) could not be found at runtime.\n",
        "If you installed SymEngine with Conda, make sure your Conda environment is activated before starting R.\n",
        "If you installed with Homebrew, make sure /usr/local/lib or /opt/homebrew/lib is in your library path.\n",
        "Original error:\n",
        conditionMessage(e)
      )
      stop(msg, call. = FALSE)
    }
  )
}

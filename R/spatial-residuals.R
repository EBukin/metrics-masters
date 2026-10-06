#' Residuals of a spatial panel fit, in panel order
#'
#' `splm::spml()` stacks the observations by period, then unit, so its
#' residuals do not line up with the `pdata.frame` they were fitted on.
#' This puts them back in unit-major order, so they can be stored in the
#' panel and tested with `plm::pcdtest()` or `splm::rwtest()`.
#'
#' @param fit An `splm` object.
#' @param index The index of the fitted `pdata.frame`, `plm::index(d)`.
#' @return A numeric vector in the order of the `pdata.frame`.
#' @export
splm_residuals <- function(fit, index) {
  r <- stats::residuals(fit)
  out <- numeric(length(r))
  out[order(index[[2]], index[[1]])] <- r
  out
}

#' Spatially filtered innovations of a spatial error model
#'
#' A spatial error model's residuals `u = y - X b` are correlated across
#' neighbours by construction: that is what the model says. The innovations
#' `(I - lambda W) u`, period by period, are what the model claims to be
#' free of spatial correlation, so they are what a residual check tests.
#'
#' @param u Residuals in `pdata.frame` order (unit-major).
#' @param w The N x N weights matrix, units in the order of the panel index.
#' @param lambda The estimated spatial error parameter.
#' @param index The panel index, `plm::index(d)`.
#' @return A numeric vector in the same order as `u`.
#' @export
spatial_filter <- function(u, w, lambda, index) {
  m <- tapply(u, list(index[[1]], index[[2]]), identity)
  e <- (diag(nrow(w)) - lambda * w) %*% m
  e[cbind(as.integer(index[[1]]), as.integer(index[[2]]))]
}

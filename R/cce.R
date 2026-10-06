#' Partial the cross-section averages out of a panel variable
#'
#' The common correlated effects transformation, one unit at a time: regress
#' the unit's series on a constant and the cross-section averages of the
#' model's variables, and keep the residual. Pooled OLS on variables
#' transformed this way is the CCEP estimator of Pesaran (2006), and a
#' spatial model fitted to them is the second stage of Bailey, Holly and
#' Pesaran (2016).
#'
#' @param v A numeric vector in `pdata.frame` order (unit-major).
#' @param avg A matrix with one column per cross-section average, aligned
#'   row by row with `v`: each row holds the period's averages.
#' @param id The unit index, same length as `v`.
#' @return A numeric vector of residuals, same length and order as `v`.
#' @export
cce_partial <- function(v, avg, id) {
  out <- numeric(length(v))
  for (ii in split(seq_along(v), id)) {
    out[ii] <- stats::residuals(stats::lm(v[ii] ~ avg[ii, , drop = FALSE]))
  }
  out
}

#' Direct, indirect and total effects of a spatial lag model
#'
#' In `y = rho W y + X b + u` the effect of regressor k is the N x N matrix
#' `(I - rho W)^-1 b_k` (LeSage and Pace 2009, chapter 2). Its average
#' diagonal is the direct effect, feedback included; its average row sum
#' is the total effect; the difference is the indirect effect, what spills
#' to other units.
#'
#' @param rho The spatial lag parameter.
#' @param beta A named vector of slopes.
#' @param w The N x N row-standardised weights matrix.
#' @return A matrix with one row per slope and columns `direct`,
#'   `indirect` and `total`.
#' @export
sar_impacts <- function(rho, beta, w) {
  s <- solve(diag(nrow(w)) - rho * w)
  direct <- mean(diag(s)) * beta
  total <- mean(rowSums(s)) * beta
  cbind(direct = direct, indirect = total - direct, total = total)
}

#' Monte Carlo standard errors for the impacts of a spatial lag model
#'
#' Draws the lag parameter and the slopes from the fit's asymptotic normal
#' distribution and recomputes the impacts for each draw (LeSage and Pace
#' 2009, section 5.2).
#'
#' @param fit An `splm` fit with a spatial lag, from `splm::spml(lag =
#'   TRUE)` with `model = "within"`, whose `coef()` holds the lag parameter
#'   under the name `lambda` next to the slopes.
#' @param w The weights matrix.
#' @param reps Number of draws.
#' @return A list with `estimate`, the impacts at the point estimates, and
#'   `se`, their Monte Carlo standard errors, matrices of the same shape.
#' @export
sar_impacts_mc <- function(fit, w, reps = 200) {
  est <- stats::coef(fit)
  v <- fit$vcov
  z <- matrix(stats::rnorm(reps * length(est)), reps) %*% chol(v)
  draws <- sweep(z, 2, est, "+")
  is_lag <- names(est) == "lambda"
  imp <- lapply(seq_len(reps), function(r) {
    sar_impacts(draws[r, is_lag], draws[r, !is_lag], w)
  })
  se <- apply(simplify2array(imp), c(1, 2), stats::sd)
  list(estimate = sar_impacts(est[is_lag], est[!is_lag], w), se = se)
}

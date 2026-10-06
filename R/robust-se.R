#' The nine covariance estimators of Croissant and Millo's Example 5.4
#'
#' A named list of functions, each taking a `plm` fit and returning a
#' covariance matrix (Croissant and Millo 2019, section 5.1.5): `OLS` the
#' conventional one; `Vw` White's, `plm::vcovHC(method = "white1")`;
#' `Vcx` and `Vct` Arellano's, clustered by unit and by time; `Vcxt` the
#' double clustering `Vcx + Vct - Vw`; `Vct.L` time clustering with every
#' lag weighted one, `plm::vcovSCC(wj = 1)`; `Vnw.L` Newey-West,
#' `plm::vcovNW()`; `Vscc.L` Driscoll-Kraay, `plm::vcovSCC()`; `Vcxt.L`
#' double clustering with lags, `Vct.L + Vcx - Vnw.L` with the Newey-West
#' lags weighted one (CM eq. 5.12).
#'
#' @return A named list of nine functions.
#' @export
vcov_menu <- function() {
  one <- function(j, maxlag) 1
  vw <- function(x) plm::vcovHC(x, method = "white1")
  vcx <- function(x) plm::vcovHC(x, cluster = "group", method = "arellano")
  vct <- function(x) plm::vcovHC(x, cluster = "time", method = "arellano")
  vct_l <- function(x) plm::vcovSCC(x, wj = one)
  list(
    OLS = function(x) stats::vcov(x),
    Vw = vw,
    Vcx = vcx,
    Vct = vct,
    Vcxt = function(x) vcx(x) + vct(x) - vw(x),
    Vct.L = vct_l,
    Vnw.L = function(x) plm::vcovNW(x),
    Vscc.L = function(x) plm::vcovSCC(x),
    Vcxt.L = function(x) vct_l(x) + vcx(x) - plm::vcovNW(x, wj = one)
  )
}

#' Standard errors of one fit under several covariance estimators
#'
#' @param fit A `plm` fit.
#' @param menu A named list of functions from a fit to a covariance matrix,
#'   by default `vcov_menu()`.
#' @param ratio If `TRUE`, divide every row by the first, so the table
#'   shows how much each estimator inflates the first row's standard
#'   errors.
#' @return A matrix, one row per estimator in `menu`, one column per
#'   coefficient.
#' @export
se_table <- function(fit, menu = vcov_menu(), ratio = FALSE) {
  se <- t(sapply(menu, function(v) sqrt(diag(v(fit)))))
  if (ratio) se <- sweep(se, 2, se[1, ], "/")
  se
}

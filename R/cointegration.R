#' Johansen's trace test, one unit at a time
#'
#' Splits a panel by its unit index, orders each unit by time, and runs
#' `urca::ca.jo(type = "trace", spec = "longrun")` on the two series named
#' in `vars`. `ca.jo` refuses an unnamed matrix, so the columns are named
#' after `vars`. The loop is plumbing: the chapter spells the call out once
#' in the open for a single state and uses this for the other 48.
#'
#' The 5 % decision is sequential and reads `@teststat` and `@cval` in
#' `ca.jo`'s order, r <= 1 first and r = 0 last: rank 0 when the r = 0
#' trace statistic is below its critical value, rank 1 when it is above but
#' the r <= 1 statistic is below, rank 2 otherwise. The slope is the
#' long-run relation `vars[1] = slope * vars[2]` implied by the first
#' cointegrating vector, `-V[2, 1] / V[1, 1]`.
#'
#' @param data A `pdata.frame`.
#' @param vars Two column names of `data`, the dependent series first.
#' @param log Take logs of both series first?
#' @param ecdet Deterministic term in the long-run relation, passed to
#'   `urca::ca.jo()`: `"none"`, `"const"` or `"trend"`.
#' @param K Lag order of the VAR in levels, passed to `urca::ca.jo()`.
#' @param label Optional column of `data` whose first value per unit labels
#'   the row, e.g. a state name beside a numeric unit index.
#' @return A data frame with one row per unit: `unit`, `label` when asked
#'   for, `trace_r0`, `cv_r0`, `trace_r1`, `cv_r1` (the two trace statistics
#'   and their 5 % critical values), `rank` and `slope`.
#' @export
johansen_by_unit <- function(data, vars, log = TRUE, ecdet = "none", K = 2,
                             label = NULL) {
  if (!inherits(data, "pdata.frame")) {
    cli::cli_abort("{.arg data} must be a {.cls pdata.frame}.")
  }
  if (length(vars) != 2 || !all(vars %in% names(data))) {
    cli::cli_abort(c(
      "{.arg vars} must name two columns of {.arg data}.",
      "x" = "Got {.val {vars}}."
    ))
  }
  idx <- plm::index(data)
  rows <- split(seq_len(nrow(data)), droplevels(idx[[1]]))
  out <- lapply(names(rows), function(u) {
    i <- rows[[u]][order(idx[[2]][rows[[u]]])]
    m <- sapply(vars, function(v) as.numeric(data[[v]])[i])
    if (log) m <- log(m)
    z <- urca::ca.jo(m, type = "trace", ecdet = ecdet, K = K,
                     spec = "longrun")
    ts <- z@teststat
    cv <- z@cval[, "5pct"]
    rank <- if (ts[2] <= cv[2]) 0L else if (ts[1] <= cv[1]) 1L else 2L
    data.frame(unit = u, trace_r0 = ts[2], cv_r0 = cv[2],
               trace_r1 = ts[1], cv_r1 = cv[1], rank = rank,
               slope = -z@V[2, 1] / z@V[1, 1])
  })
  out <- do.call(rbind, out)
  rownames(out) <- NULL
  if (!is.null(label)) {
    first <- vapply(rows, function(i) i[1], integer(1))
    out <- cbind(out[1], label = as.character(data[[label]])[first],
                 out[-1])
  }
  out
}

#' A panel series as a time-by-unit matrix
#'
#' `pco::pedroni99()` wants each series as a `T x N` matrix, time in rows,
#' units in columns, with no `NA`. Pass a `pdata.frame` and an expression
#' in its columns, `panel_wide(php, log(price))`, or a `pseries` on its own,
#' `panel_wide(residuals(fit))`.
#'
#' @param data A `pdata.frame`, or a `pseries` when `expr` is missing.
#' @param expr An expression in the columns of `data`.
#' @return A `T x N` numeric matrix, the time levels as row names and the
#'   unit levels as column names. A cell missing for some units, or an `NA`
#'   value, is an error; a period absent from every unit is dropped.
#' @export
panel_wide <- function(data, expr) {
  if (missing(expr)) {
    if (!inherits(data, "pseries")) {
      cli::cli_abort(
        "Without {.arg expr}, {.arg data} must be a {.cls pseries}."
      )
    }
    return(wide_by_index(data, plm::index(data)))
  }
  if (!inherits(data, "pdata.frame")) {
    cli::cli_abort("{.arg data} must be a {.cls pdata.frame}.")
  }
  x <- eval(substitute(expr), data, parent.frame())
  wide_by_index(x, plm::index(data))
}

#' Several panel series as a time-by-unit-by-variable array
#'
#' `pco::pedroni99m()` wants a `T x N x M` array with the dependent variable
#' in sheet 1. It drops `X[, , 2:M]` to a matrix when `M = 2` and fails with
#' "incorrect number of dimensions", so it needs `M >= 3`; the bivariate
#' case goes through `panel_wide()` and `pco::pedroni99()`.
#'
#' @param data A `pdata.frame`.
#' @param ... Expressions in the columns of `data`, the dependent variable
#'   first. A named argument names its sheet; an unnamed one is named after
#'   its expression.
#' @return A `T x N x M` numeric array with dimnames.
#' @export
panel_array <- function(data, ...) {
  if (!inherits(data, "pdata.frame")) {
    cli::cli_abort("{.arg data} must be a {.cls pdata.frame}.")
  }
  exprs <- as.list(substitute(list(...)))[-1]
  if (length(exprs) == 0) {
    cli::cli_abort("{.fn panel_array} needs at least one series in {.arg ...}.")
  }
  env <- parent.frame()
  idx <- plm::index(data)
  mats <- lapply(exprs, function(e) wide_by_index(eval(e, data, env), idx))
  nm <- names(exprs)
  dep <- vapply(exprs, function(e) paste(deparse(e), collapse = ""), "")
  if (is.null(nm)) nm <- dep else nm[nm == ""] <- dep[nm == ""]
  array(unlist(mats), dim = c(dim(mats[[1]]), length(mats)),
        dimnames = c(dimnames(mats[[1]]), list(nm)))
}

#' Dickey-Fuller t statistics, one unit at a time
#'
#' Runs `urca::ur.df()` on each unit's series and returns the t statistic
#' on the lagged level, the first entry of `@teststat`. On the residual of a
#' levels regression this is the Engle-Granger statistic of that unit, and
#' the Dickey-Fuller critical values do not apply to it.
#'
#' @param resid A `pseries`, or a `T x N` matrix with units in columns.
#' @param lags Number of lagged differences, passed to `urca::ur.df()`.
#' @param type Deterministic part of the test regression, passed to
#'   `urca::ur.df()`: `"none"`, `"drift"` or `"trend"`.
#' @return A named numeric vector, one t statistic per unit.
#' @export
adf_by_unit <- function(resid, lags = 2, type = "none") {
  m <- if (is.matrix(resid)) resid else panel_wide(resid)
  apply(m, 2, function(y) {
    urca::ur.df(y, type = type, lags = lags)@teststat[1]
  })
}

#' Simulate a panel of pairs with or without a shared trend
#'
#' Each of `n` units gets its own random walk `x`. Without cointegration
#' `y` is a second, independent random walk. With it, `y = 1 + x + 0.5 e`
#' with white-noise `e`, so the gap `y - x` is stationary in every unit.
#' The units are independent either way. This is the design of the size
#' and power check of `pco::pedroni99()` in the time chapter: the two
#' matrices go straight into `pco::pedroni99(sim$Y, sim$X)`.
#'
#' @param n Number of units.
#' @param t Number of periods.
#' @param coint Do `y` and `x` share a trend?
#' @return A list of two `t x n` matrices, `Y` and `X`, time in rows.
#' @export
sim_coint_pair_panel <- function(n, t, coint = FALSE) {
  rw <- function() apply(matrix(stats::rnorm(t * n), t, n), 2, cumsum)
  x <- rw()
  y <- if (coint) 1 + x + 0.5 * matrix(stats::rnorm(t * n), t, n) else rw()
  dimnames(x) <- dimnames(y) <- list(seq_len(t), seq_len(n))
  list(Y = y, X = x)
}

#' Spread an indexed vector over its time-by-unit grid
#'
#' @param x A vector in the row order of `idx`; a `pseries` is coerced.
#' @param idx The two-column index of `x`, unit then time, as
#'   `plm::index()` returns it.
#' @return A `T x N` numeric matrix with dimnames.
#' @noRd
wide_by_index <- function(x, idx) {
  unit <- droplevels(idx[[1]])
  time <- droplevels(idx[[2]])
  if (length(x) != length(unit)) {
    cli::cli_abort(c(
      "The series and the index differ in length.",
      "x" = "{length(x)} values against {length(unit)} index rows."
    ))
  }
  m <- matrix(NA_real_, nlevels(time), nlevels(unit),
              dimnames = list(levels(time), levels(unit)))
  m[cbind(as.integer(time), as.integer(unit))] <- as.numeric(x)
  n_na <- sum(is.na(m))
  if (n_na > 0) {
    cli::cli_abort(c(
      "The series has {n_na} missing cell{?s} on the T x N grid.",
      "i" = "{.fn pco::pedroni99} needs a balanced panel with no {.val NA}."
    ))
  }
  m
}

#' Simulate an AR(1) series
#'
#' Draws one AR(1) series with standard normal innovations, after discarding
#' a burn-in so the start value does not matter. `rho = 1` gives a random
#' walk.
#'
#' @param t Number of periods to keep.
#' @param rho Autoregressive root.
#' @param burn Number of initial periods to discard.
#' @return A numeric vector of length `t`.
#' @export
sim_ar1 <- function(t, rho, burn = 50) {
  y <- Reduce(function(a, e) rho * a + e, stats::rnorm(t + burn),
              accumulate = TRUE)
  y[-seq_len(burn)]
}

#' Simulate a panel with a known number of stationary series
#'
#' The first `k` series are stationary AR(1) with root `rho`; the remaining
#' `n - k` are random walks. Units are independent.
#'
#' @param n Number of units.
#' @param t Number of periods.
#' @param k Number of stationary units.
#' @param rho Root of the stationary units.
#' @return A `t` x `n` matrix, one column per unit.
#' @export
sim_ar_panel <- function(n, t, k, rho = 0.5) {
  sapply(seq_len(n), function(i) sim_ar1(t, if (i <= k) rho else 1))
}

#' Simulate independent random walks
#'
#' @param n Number of units.
#' @param t Number of periods.
#' @return A `t` x `n` matrix, one random walk per column.
#' @export
sim_rw_panel <- function(n, t) {
  apply(matrix(stats::rnorm(t * n), t, n), 2, cumsum)
}

#' Rook-contiguity weights on a square grid
#'
#' Each cell of a `side` x `side` grid neighbours the cells directly above,
#' below, left and right of it. Rows are standardised to sum to one.
#'
#' @param side Number of cells along one side of the grid.
#' @return A `side^2` x `side^2` row-standardised weights matrix.
#' @export
rook_w <- function(side) {
  cells <- expand.grid(row = seq_len(side), col = seq_len(side))
  neighbour <- as.matrix(stats::dist(cells, method = "manhattan")) == 1
  neighbour / rowSums(neighbour)
}

#' Simulate random walks with spatially correlated shocks
#'
#' Every series is a random walk, so the unit-root null is true. Each
#' period's shocks spill over through `(I - lambda W)^-1`: `lambda = 0` is
#' independence, values near one are strong spatial dependence.
#'
#' @param w Row-standardised weights matrix.
#' @param lambda Spatial autoregressive parameter of the shocks.
#' @param t Number of periods.
#' @return A `t` x `nrow(w)` matrix, one random walk per column.
#' @export
sim_spatial_rw_panel <- function(w, lambda, t = 30) {
  spill <- solve(diag(nrow(w)) - lambda * w)
  eps <- matrix(stats::rnorm(t * nrow(w)), t, nrow(w))
  apply(eps %*% t(spill), 2, cumsum)
}

#' Simulate two series that share one stochastic trend
#'
#' Both series load on the same random walk, so `1.3 a - 0.8 b` is
#' stationary: the pair is cointegrated.
#'
#' @param t Number of periods.
#' @return A `t` x 2 matrix with columns `a` and `b`.
#' @export
sim_factor_pair <- function(t = 100) {
  f <- cumsum(stats::rnorm(t))
  cbind(a = 0.8 * f + stats::rnorm(t), b = 1.3 * f + stats::rnorm(t))
}

#' Simulate two random walks with correlated shocks
#'
#' Each series has its own stochastic trend; only the shocks are correlated,
#' at 0.8. No linear combination is stationary: the pair is not
#' cointegrated, however closely the two move together.
#'
#' @param t Number of periods.
#' @return A `t` x 2 matrix with columns `a` and `b`.
#' @export
sim_correlated_pair <- function(t = 100) {
  chol_r <- chol(matrix(c(1, 0.8, 0.8, 1), 2))
  shocks <- matrix(stats::rnorm(2 * t), t, 2) %*% chol_r
  m <- apply(shocks, 2, cumsum)
  colnames(m) <- c("a", "b")
  m
}

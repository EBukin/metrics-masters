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

#' Simulate a panel with unit-specific slopes and spatially correlated shocks
#'
#' `y_it = a_i + b_i x_it + u_it`, with slopes `b_i ~ N(1, sd_b^2)` and
#' each period's shocks spilling over through `(I - lambda W)^-1`, as in
#' `sim_spatial_rw_panel()` but stationary. The mean slope is 1.
#'
#' @param w Row-standardised weights matrix.
#' @param lambda Spatial autoregressive parameter of the shocks.
#' @param t Number of periods.
#' @param sd_b Standard deviation of the slopes across units.
#' @return A `pdata.frame` with columns `id`, `period`, `y` and `x`.
#' @export
sim_spatial_slope_panel <- function(w, lambda, t = 20, sd_b = 0.3) {
  n <- nrow(w)
  spill <- solve(diag(n) - lambda * w)
  b <- stats::rnorm(n, 1, sd_b)
  a <- stats::rnorm(n)
  x <- matrix(stats::rnorm(t * n), t, n)
  e <- matrix(stats::rnorm(t * n), t, n) %*% t(spill)
  y <- sweep(sweep(x, 2, b, "*"), 2, a, "+") + e
  as_pdata(y, x)
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

#' Simulate a dynamic panel with fixed effects
#'
#' Draws `y_it = gamma * y_i,t-1 + alpha_i + e_it` for `n` independent units,
#' with `alpha_i ~ N(0, 1)` and `e_it ~ N(0, 1)`, after discarding a burn-in
#' so the start value does not matter. `t + 1` periods are kept, so a
#' regression on one lag uses exactly `t` periods per unit: `t` is the number
#' of periods in the regression after one lag is taken. The within estimator
#' of `gamma` on this panel is biased by `nickell_bias(gamma, t)`.
#'
#' @param n Number of units.
#' @param t Number of periods in the regression after one lag is taken.
#' @param gamma Autoregressive coefficient.
#' @param burn Number of initial periods to discard.
#' @return A `pdata.frame` with columns `id`, `period` and `y`, holding
#'   `t + 1` periods per unit.
#' @export
sim_dynamic_panel <- function(n, t, gamma = 0.5, burn = 50) {
  alpha <- stats::rnorm(n)
  y <- sapply(alpha, function(a) {
    s <- Reduce(function(prev, e) gamma * prev + a + e,
                stats::rnorm(t + 1 + burn), accumulate = TRUE)
    s[-seq_len(burn)]
  })
  long <- data.frame(id = rep(seq_len(n), each = t + 1),
                     period = rep(seq_len(t + 1), n),
                     y = as.vector(y))
  plm::pdata.frame(long, index = c("id", "period"))
}

#' Exact large-N bias of the within estimator in a dynamic panel
#'
#' The within estimator of `gamma` in `y_it = gamma * y_i,t-1 + alpha_i +
#' e_it` is inconsistent when `t` is fixed and `n` grows. This is its exact
#' large-`n` bias (Nickell 1981), as printed in Pesaran (2015), eq. 27.11:
#'
#' `-(1 + gamma) / (t - 1) * A / (1 - 2 * gamma * A / ((1 - gamma) * (t - 1)))`
#'
#' with `A = 1 - (1 - gamma^t) / (t * (1 - gamma))`. The leading term is
#' `-(1 + gamma) / (t - 1)`, which the full expression approaches as `t`
#' grows.
#'
#' @param gamma Autoregressive coefficient, `abs(gamma) < 1`.
#' @param t Number of periods in the regression after one lag is taken, as
#'   in `sim_dynamic_panel()`.
#' @return The bias `plim(gamma_hat) - gamma`, recycled over `gamma` and `t`.
#' @references Nickell, S. (1981). Biases in dynamic models with fixed
#'   effects. Econometrica 49(6), 1417--1426. Pesaran, M. H. (2015). Time
#'   Series and Panel Data Econometrics. Oxford University Press, eq. 27.11.
#' @export
nickell_bias <- function(gamma, t) {
  a <- 1 - (1 - gamma^t) / (t * (1 - gamma))
  -(1 + gamma) / (t - 1) * a / (1 - 2 * gamma * a / ((1 - gamma) * (t - 1)))
}

#' Roy-Zellner test for poolability under random effects
#'
#' Chow's F test of equal coefficients across units, run on the data after
#' the random-effects (GLS) transformation (Baltagi 2021, section 4.1.3).
#' The one-way variance components give theta through `plm::ercomp()`; y
#' and X are then transformed by `Within + (1 - theta) Between`, so the
#' intercept becomes `1 - theta`. The unrestricted model gives every unit
#' its own coefficients, the restricted one pools them.
#'
#' @param formula The model formula.
#' @param data A `pdata.frame`, or a data frame whose first two columns are
#'   the unit and time indexes.
#' @param effect `"individual"` tests equal coefficients across units,
#'   `"time"` across periods; the GLS transformation uses the same effect.
#' @return An `htest` with the F statistic, its degrees of freedom
#'   `(N - 1) K'` and `N (T - K')`, where `K'` counts the intercept, and the
#'   p-value.
#' @export
roy_zellner <- function(formula, data, effect = "individual") {
  effect <- match.arg(effect, c("individual", "time"))
  if (!inherits(data, "pdata.frame")) data <- plm::pdata.frame(data)
  if (!plm::pdim(data)$balanced) {
    cli::cli_abort(c(
      "{.fn roy_zellner} needs a balanced panel.",
      "x" = "{.arg data} is unbalanced: the units differ in T."
    ))
  }
  theta <- plm::ercomp(formula, data, effect = effect)$theta
  pooled <- plm::plm(formula, data, model = "pooling")
  y <- plm::pmodel.response(pooled)
  x <- model.matrix(pooled)
  ys <- as.numeric(
    plm::Within(y, effect = effect) +
      (1 - theta) * plm::Between(y, effect = effect)
  )
  xs <- plm::Within(x, effect = effect) +
    (1 - theta) * plm::Between(x, effect = effect)
  g <- plm::index(pooled)[[if (effect == "individual") 1L else 2L]]
  rss <- function(yy, xx) sum(stats::lm.fit(xx, yy)$residuals^2)
  rrss <- rss(ys, xs)
  urss <- sum(tapply(seq_along(ys), g, function(i) {
    rss(ys[i], xs[i, , drop = FALSE])
  }))
  n <- nlevels(g)
  t <- length(ys) / n
  k <- ncol(xs)
  df1 <- (n - 1) * k
  df2 <- n * (t - k)
  f <- (rrss - urss) / df1 / (urss / df2)
  structure(
    list(
      statistic = c(F = f),
      parameter = c(df1 = df1, df2 = df2),
      p.value = stats::pf(f, df1, df2, lower.tail = FALSE),
      method = paste("Roy-Zellner test for poolability across",
                     if (effect == "individual") "units" else "periods"),
      data.name = deparse(formula)
    ),
    class = "htest"
  )
}

#' Turn a wide matrix into a panel series
#'
#' `plm::cipstest()` accepts only a `pseries`. This stacks a `t` x `n` matrix
#' (one column per unit) into long form and returns the indexed series.
#'
#' @param m A `t` x `n` numeric matrix.
#' @return A `pseries` indexed by unit `id` and `period`.
#' @export
as_pseries <- function(m) {
  long <- data.frame(id = rep(seq_len(ncol(m)), each = nrow(m)),
                     period = rep(seq_len(nrow(m)), ncol(m)),
                     y = as.vector(m))
  plm::pdata.frame(long, index = c("id", "period"))$y
}

#' Turn two wide matrices into a long panel data frame
#'
#' Stacks an outcome matrix and a regressor matrix of the same shape into
#' one `pdata.frame`, ready for `plm::plm()`.
#'
#' @param y,x `t` x `n` numeric matrices, one column per unit.
#' @return A `pdata.frame` with columns `id`, `period`, `y` and `x`.
#' @export
as_pdata <- function(y, x) {
  long <- data.frame(id = rep(seq_len(ncol(y)), each = nrow(y)),
                     period = rep(seq_len(nrow(y)), ncol(y)),
                     y = as.vector(y), x = as.vector(x))
  plm::pdata.frame(long, index = c("id", "period"))
}

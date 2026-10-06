#' The 49 state polygons behind `usaw49`
#'
#' `pder::usaw49` names its rows in upper case with underscores, and spells
#' Tennessee without its last letter. This returns `spData::us_states` with
#' its rows in the order of `usaw49`, which is also the order of the states
#' in `pder::HousePricesUS`, so maps, weights and the panel line up.
#'
#' @return An `sf` data frame of 49 polygons, 48 states and the District of
#'   Columbia.
#' @export
us_states_sf <- function() {
  us <- sf::st_as_sf(spData::us_states)
  usaw49 <- NULL
  utils::data("usaw49", package = "pder", envir = environment())
  nm <- gsub("_", " ", rownames(usaw49))
  nm[nm == "TENNESSE"] <- "TENNESSEE"
  us[match(nm, toupper(us$NAME)), ]
}

#' Draw the links of a weights matrix between unit centroids
#'
#' @param geometry An `sfc` of polygons, in the order of `w`.
#' @param w A weights matrix; every non-zero cell is a link.
#' @param ... Passed to `graphics::segments()`, e.g. `col`.
#' @return Invisibly, the centroid coordinates.
#' @export
draw_links <- function(geometry, w, ...) {
  xy <- sf::st_coordinates(sf::st_centroid(geometry))
  ij <- which(w > 0, arr.ind = TRUE)
  graphics::segments(xy[ij[, 1], 1], xy[ij[, 1], 2],
                     xy[ij[, 2], 1], xy[ij[, 2], 2], ...)
  invisible(xy)
}

#' Pre-checks on a spatial weights matrix
#'
#' The four checks of Pesaran (2015, section 30.3): the matrix norms that
#' bound the parameter space, the eigenvalue bounds, the largest weight
#' (granularity), and how much denser `(I - rho W)^-1` is than `W`.
#'
#' @param w A weights matrix.
#' @param rho The spatial parameter at which to evaluate the inverse.
#' @return A named numeric vector.
#' @export
w_checks <- function(w, rho = 0.5) {
  ev <- Re(eigen(w, only.values = TRUE)$values)
  inv <- solve(diag(nrow(w)) - rho * w)
  c(norm_1 = max(colSums(w)), norm_inf = max(rowSums(w)),
    rho_min = 1 / min(ev), rho_max = 1 / max(ev),
    max_weight = max(w), nonzero_w = mean(w > 0),
    nonzero_inverse = mean(abs(inv) > 1e-8))
}

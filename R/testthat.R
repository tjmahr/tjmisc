# Custom functions for package testing


expect_nrow <- function(object, n) {
  stopifnot(is.numeric(n), length(n) == 1)
  lab <- rlang::expr_label(rlang::enexpr(object))

  if (!is.data.frame(object) && !is.matrix(object) && !is.array(object)) {
    rlang::abort((sprintf("%s does not have rows.", lab)))
  }

  # singular/plural alternation
  has_msg <- ngettext(nrow(object), "row", "rows")
  not_msg <- ngettext(n, "row", "rows")

  testthat::expect(
    nrow(object) == n,
    sprintf("%s has %i %s, not %i %s.",
            lab, nrow(object), has_msg, n, not_msg))

  invisible(object)
}
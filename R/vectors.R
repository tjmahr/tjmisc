# Vector related helpers

#' Check for locally repeating values
#'
#' @rdname is_same_as_last
#' @param xs a vector
#' @param replacement a value used to replace a repeated value. Defaults to
#'   `""`.
#' @return `is_same_as_last()` returns TRUE when `xs[n]` the same as `xs[n-1]`.
#' @export
#' @examples
#' xs <- c("a", "a", "a", NA, "b", "b", "c", NA, NA)
#' is_same_as_last(xs)
#' replace_if_same_as_last(xs, "")
is_same_as_last <- function(xs) {
  same_as_last <- unlist(Map(identical, xs, dplyr::lag(xs)), use.names = FALSE)
  # Overwrite NA (first lag) from lag(xs)
  same_as_last[1] <- FALSE
  same_as_last
}


#' @rdname is_same_as_last
#' @export
replace_if_same_as_last <- function(xs, replacement = "") {
  xs[is_same_as_last(xs)] <- replacement
  xs
}


#' Add a count to the labels of a factor
#'
#' @param xs a factor
#' @param fmt glue-style format to use. Defaults to `"{levels} ({counts})"`
#' @param first_fmt glue-style format to use for very first label. Defaults to
#'   value of `fmt`.
#' @return a factor with the labels updated
#' @export
fct_add_counts <- function(xs, fmt = "{levels} ({counts})", first_fmt = fmt) {
  levels <- names(table(xs))
  counts <- unname(table(xs))
  with_counts <- as.character(glue::glue(fmt))
  with_counts[1] <- as.character(glue::glue(first_fmt))[1]
  factor(xs, levels, labels = with_counts)
}

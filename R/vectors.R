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



#' Format the labels of a factor
#'
#' @param xs a factor
#' @param fmt glue-style format to use. Defaults to `"{levels}"` for
#'   `fct_glue_labels()` and `"{levels} ({counts})"` for `fct_add_counts()`.
#' @param first_fmt glue-style format to use for very first label. Defaults to
#'   value of `fmt`.
#' @return a factor with the labels updated
#'
#' @details At this point, only the magic variables `"{levels}"` and
#'   `"{counts}"` are available ". In principle, others could be defined.
#'   `fct_add_counts()` is a special case of `fct_glue_labels()`.
#'
#' @export
#' @rdname fct_glue_labels
fct_glue_labels <- function(xs, fmt = "{levels}", first_fmt = fmt) {
  levels <- names(table(xs))
  counts <- unname(table(xs))
  labels <- as.character(glue::glue(fmt))
  labels[1] <- as.character(glue::glue(first_fmt))[1]
  factor(xs, levels, labels = labels)
}


#' @export
#' @rdname fct_glue_labels
fct_add_counts <- function(xs, fmt = "{levels} ({counts})", first_fmt = fmt) {
  fct_glue_labels(xs, fmt, first_fmt)
}


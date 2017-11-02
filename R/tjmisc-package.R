#' @keywords internal
#' @import dplyr
#' @importFrom utils modifyList
"_PACKAGE"

# This is where I put as-yet unsupported helpers.







wrap_with_defaults <- function(func, hard_defaults, soft_defaults) {
  soft_defaults <- force(soft_defaults)
  hard_defaults <- force(hard_defaults)
  function(...) {
    dots <- list(...)
    # overwrite soft defaults with user options
    # then overwrite with hard defaults
    args <- modifyList(modifyList(soft_defaults, dots), hard_defaults)
    do.call(func, args)
  }
}

#' Create a sequence along the rows of a dataframe
#' @param data a dataframe
#' @return a sequence of integers along the rows of a dataframe
#' @noRd
seq_along_rows <- function(data) {
  seq_len(nrow(data))
}


# fct_add_counts <- function(f) {
#   counts <- forcats::fct_count(f)
#   counts[["new"]] <- sprintf("%s (%s)", counts[["f"]], counts[["n"]])
#   x <- setNames(counts[["new"]], counts[["f"]])
#   forcats::fct_relabel(f, function(level) x[level])
# }


#' Resequence a set of integer indices
#'
#' This function is useful for plotting by indices when there are gaps between
#' some indices' values. For example, if some subject IDs are numbered in the
#' 100's for group x and the 300's for group y, then when subject ID is used as
#' the x-axis in a plot, the plot axis would include all the empty indices
#' separating the two groups (which is ugly). Resequencing the IDs would remove
#' that gap, while preserving the relative ordering of the indices.
#'
#' @examples
#' resequence(c(10, 1, 3, 8, 10, 10))
#' #> [1] 4 1 2 3 4 4
#' @noRd
resequence <- function(xs) {
  keys <- sort(unique(xs))
  values <- seq_along(keys)
  unname(rlang::set_names(values, keys)[as.character(xs)])
}

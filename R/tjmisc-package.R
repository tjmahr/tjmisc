#' @keywords internal
"_PACKAGE"




#' Create a sequence along the rows of a dataframe
#' @param data a dataframe
#' @return a sequence of integers along the rows of a dataframe
#' @noRd
seq_along_rows <- function(data) {
  seq_len(nrow(data))
}


fct_add_counts <- function(f) {
  counts <- forcats::fct_count(f)
  counts[["new"]] <- sprintf("%s (%s)", counts[["f"]], counts[["n"]])
  x <- setNames(counts[["new"]], counts[["f"]])
  forcats::fct_relabel(f, function(level) x[level])
}


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
  unname(setNames(values, keys)[as.character(xs)])
}

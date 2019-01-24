#' @keywords internal
#' @import dplyr
#' @importFrom utils modifyList
"_PACKAGE"

# This is where I put as-yet unsupported helpers.





#' Filter out strings that match a pattern
#' @param string Input vector. Either a character vector, or something coercible
#'   to one.
#' @param pattern Pattern to look for
#' @return A character vector of strings that don't match the pattern.
#' @noRd
# str_reject <- function(string, pattern) {
#   matches <- Negate(stringr::str_detect)(string, pattern)
#   string[matches]
# }



## Actually dplyr has stronger versions of these
# first <- function(...) head(..., n = 1)
# last <- function(...) tail(..., n = 1)

## But not this
# but_last <- function(...) head(..., n = -1)

length_zero <- function(x) length(x) == 0
length_one <- function(x) length(x) == 1


# is.error <- function(x) inherits(x, "try-error")
# `%contains%` <- function(x, y) any(y %in% x)
# `%lacks%` <- function(x, y) !any(y %in% x)
# is_all_na <- function(x) all(is.na(x))


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



merge_lists <- function(x, y) {
  x[names(y)] <- y
  x
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
  unname(rlang::set_names(values, keys)[as.character(xs)])
}

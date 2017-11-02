
#' Randomly sample data from n sub-groups of data
#'
#' @param data a dataframe
#' @param size number of groups to sample
#' @param ... variables to group by
#' @return the data from subgroups
#' @export
#' @examples
#' sample_data <- tibble::tibble(
#'   letter = rep(letters, 5),
#'   color = rep(c("red", "green", "yellow", "orange", "blue"), 26),
#'   value = rnorm(26 * 5)
#' )
#'
#' # data from two letters
#' sample_data %>%
#'   sample_n_of(2, letter)
#'
#' # data from two colors
#' sample_data %>%
#'   sample_n_of(2, color)
#'
#' # data from 10 letter-colors pairs
#' sample_data %>%
#'   sample_n_of(10, letter, color)
sample_n_of <- function(data, size, ...) {
  rows <- tibble::data_frame(row = seq_len(nrow(data)))
  dots <- quos(...)

  # Default to sampling rows if no grouping variables set
  if (length(dots) == 0) {
    dots <- list(.rowid = rows$row)
  }

  rows[, "group"] <- data %>%
    dplyr::group_by(!!! dots) %>%
    dplyr::group_indices()

  n_groups <- max(rows$group)

  if (n_groups < size) {
    w <- glue::glue(
      "Sample size ({size}) is larger than number of groups ({n_groups}). ",
      "Using size = {n_groups}.")
    rlang::warn(w)
    size <- n_groups
  }

  subset <- rows %>%
    dplyr::filter(.data$group %in% sample(unique(.data$group), size)) %>%
    dplyr::pull(.data$row)

  data[subset, ]
}

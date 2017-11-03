
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


#' Compare pairs of categorical variables
#' @param data a dataframe
#' @param levels a column with a categorical variable. All pairs of values in
#'   `levels` will be compared.
#' @param values a column with values to compare.
#' @param f comparison function to apply to values in each pair. Defaults to `-`
#'   to compute the pairwise differences.
#' @return a dataframe with pairwise comparisons
#' @export
#' @examples
#' to_compare <- nlme::Machines %>%
#'   dplyr::group_by(Worker) %>%
#'   dplyr::summarise(avg_score = mean(score)) %>%
#'   print()
#'
#' to_compare %>%
#'   compare_pairs(Worker, avg_score) %>%
#'   dplyr::rename(difference = value) %>%
#'   dplyr::mutate_if(is.numeric, round, 1)
compare_pairs <- function(data, levels, values, f = `-`) {
  levels <- enquo(levels)
  values <- enquo(values)

  pairs <- data %>%
    pull(!! levels) %>%
    create_pairs()

  wide <- data %>%
    tidyr::spread(key = !! levels, value = !! values)

  for (row_i in seq_len(nrow(pairs))) {
    pair_i <- pairs[row_i, ]
    wide[, pair_i$name] <- f(wide[[pair_i$x1]], wide[[pair_i$x2]])
  }

  wide %>%
    select(-one_of(c(pairs$x1), c(pairs$x2))) %>%
    tidyr::gather("pair", "value", one_of(c(pairs$name))) %>%
    mutate(pair = factor(.data$pair, levels = pairs$name))
}


#' @importFrom utils combn
create_pairs <- function(xs) {
  if (!is.factor(xs)) xs <- ordered(xs)
  xs %>%
    levels() %>%
    rev() %>%
    combn(2) %>%
    t() %>%
    as.data.frame() %>%
    rlang::set_names("x1", "x2") %>%
    mutate(name = paste0(.data$x1, "-", .data$x2)) %>%
    mutate_all(as.character) %>%
    arrange(x1, desc(x2))
}

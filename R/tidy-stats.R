#' Generate tidy quantiles for a dataframe column
#'
#' This function respects groupings from `dplyr::group_by()`. When the dataframe
#' contains grouped data, the quantiles are computed within each subgroup of
#' data.
#'
#' @param data a dataframe
#' @param var a column in the dataframe
#' @param probs quantiles to return. Defaults to `c(.1, .3, .5, .7, .9)`
#' @return a long dataframe (a tibble) with quantiles for the variable.
#' @export
#' @examples
#' tidy_quantile(sleep, extra)
#'
#' sleep %>%
#'   dplyr::group_by(group) %>%
#'   tidy_quantile(extra)
tidy_quantile <- function(data, var, probs = seq(.1, .9, .2)) {
  UseMethod("tidy_quantile")
}

#' @export
tidy_quantile.default <- function(data, var, probs = seq(.1, .9, .2)) {
  q <- enquo(var)
  rlang::eval_tidy(q, data = data) %>%
    stats::quantile(probs, na.rm = TRUE) %>%
    tibble::enframe("quantile", value = rlang::quo_name(q))
}

#' @export
tidy_quantile.grouped_df <- function(data, var, probs = seq(.1, .9, .2)) {
  q <- enquo(var)

  groups <- split(data, group_indices(data)) %>%
    lapply(select, !!! group_vars(data)) %>%
    lapply(distinct) %>%
    lapply(ungroup) %>%
    bind_rows(.id = "....id")

  quantiles <- split(data, group_indices(data)) %>%
    lapply(ungroup) %>%
    lapply(tidy_quantile.default, !! q, probs) %>%
    bind_rows(.id = "....id")

  groups %>%
    left_join(quantiles, by = "....id") %>%
    select(-one_of("....id"))
}




#' Generate tidy correlations
#'
#' This function respects groupings from `dplyr::group_by()`. When the dataframe
#' contains grouped data, the correlations are computed within each subgroup of
#' data.
#'
#' @param data a dataframe
#' @param ... columns to select, using `dplyr::select()` semantics.
#' @param type type of correlation, either `"pearson"` (the default) or
#'   `"spearman"`.
#' @return a long dataframe (a tibble) with correlations calculated for each
#'   pair of columns.
#' @export
#' @examples
#' tidy_correlation(ChickWeight, -Chick, -Diet)
#'
#' tidy_correlation(ChickWeight, weight, Time)
#'
#' ChickWeight %>%
#'   dplyr::group_by(Diet) %>%
#'   tidy_correlation(weight, Time)
tidy_correlation <- function(data, ..., type = c("pearson", "spearman")) {
  UseMethod("tidy_correlation")
}


#' @export
tidy_correlation.grouped_df <- function(
  data,
  ...,
  type = c("pearson", "spearman")
) {
  data %>%
    summarise(
      tidy_correlation.default(cur_data_all(), ..., type = type),
      .groups = "drop"
    ) %>%
    ungroup()
}


#' @export
tidy_correlation.default <- function(
  data,
  ...,
  type = c("pearson", "spearman")
) {
  select(data, ...) %>%
    as.matrix() %>%
    Hmisc::rcorr(type = type) %>%
    broom::tidy() %>%
    tibble::remove_rownames() %>%
    tibble::as_tibble() %>%
    mutate_at(c("column1", "column2"), as.character) %>%
    mutate_if(is.numeric, round, 4)
}

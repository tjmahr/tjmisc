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
#' @importFrom stats quantile
#' @export
#' @examples
#' tidy_quantile(iris, Sepal.Length)
#'
#' iris %>%
#'   dplyr::group_by(Species) %>%
#'   tidy_quantile(Sepal.Length)
tidy_quantile <- function(data, var, probs = seq(.1, .9, .2)) {
  UseMethod("tidy_quantile")
}

#' @export
tidy_quantile.default <- function(data, var, probs = seq(.1, .9, .2)) {
  q <- enquo(var)
  rlang::eval_tidy(q, data = data) %>%
    quantile(probs, na.rm = TRUE) %>%
    tibble::enframe("quantile", value = rlang::quo_name(q))
}

#' @export
tidy_quantile.grouped_df <- function(data, var, probs = seq(.1, .9, .2)) {
  q <- enquo(var)

  groups <- split(data, dplyr::group_indices(data)) %>%
    lapply(dplyr::select, !!! dplyr::group_vars(data)) %>%
    lapply(dplyr::distinct) %>%
    lapply(dplyr::ungroup) %>%
    dplyr::bind_rows(.id = "....id")

  quantiles <- split(data, dplyr::group_indices(data)) %>%
    lapply(dplyr::ungroup) %>%
    lapply(tidy_quantile.default, !! q, probs) %>%
    dplyr::bind_rows(.id = "....id")

  groups %>%
    dplyr::left_join(quantiles, by = "....id") %>%
    dplyr::select(-dplyr::one_of("....id"))
}

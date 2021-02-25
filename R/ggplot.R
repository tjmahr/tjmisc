#' Preview a file that would be created by `ggsave()`
#'
#' This function saves a plot to a temporary file with `ggsave()` and opens the
#' temporary file in the system viewer. This function is useful for quickly
#' previewing how a plot will look when it is saved to a file.
#'
#' @param ... options passed onto [ggplot2::ggsave()]
#' @param device the file extention of the device to use. Defaults to `"png"`.
#' @export
ggpreview <- function(..., device = "png") {
  fname <- tempfile(fileext = paste0(".", device))
  ggplot2::ggsave(filename = fname, device = device, ...)
  system2("open", fname)
  invisible(NULL)
}


#' Plot columns of a matrix
#'
#' Creates plots of matrices like [graphics::matplot()] but uses ggplot2,
#' defaults to drawing lines, and can specify a column to use for the
#' *x*-axis.
#'
#' @param x A matrix.
#' @param x_axis_column Index (number) of the column to plot for the *x*-axis.
#'   Defaults to `NULL` in which case it uses row index (number) as the
#'   *x*-axis.
#' @param n_colors Number of colors to cycle through. Defaults to 6.
#' @param unique_rows Whether to work first take the unique rows of the matrix.
#'   Defaults to `TRUE`.
#' @return a ggplot2 plot.
#' @importFrom ggplot2 ggplot aes geom_line guides labs scale_color_manual
#' @export
ggmatplot <- function(
  x,
  x_axis_column = NULL,
  n_colors = 6,
  unique_rows = TRUE
) {

  if (unique_rows) {
    ux <- unique(x)
    default_x_label <- "unique row number"
  } else {
    ux <- x
    default_x_label <- "row number"
  }
  rownames(ux) <- seq_len(nrow(ux))

  # Figure out what to put on the x axis
  if (!is.null(x_axis_column)) {
    x_label <- rlang::expr_label(substitute(x[, x_axis_column]))
  } else {
    ux <- cbind(seq_len(nrow(ux)), ux)
    x_axis_column <- 1
    x_label <- default_x_label
  }

  # Reshape non-x axis columns into a long dataframe
  long_ux <- reshape2::melt(
    ux[, -x_axis_column, drop = FALSE],
    c(".row", ".column")
  )

  # Reshape axis column into a long dataframe
  x_axis <- reshape2::melt(
    ux[, x_axis_column, drop = FALSE],
    c(".row", ".x_axis_name"),
    value.name = x_label
  )
  long_ux <- merge(long_ux, x_axis)

  # cycle through colors like matplot()
  column_numbers <- match(long_ux$.column, sort(unique(long_ux$.column)))
  long_ux$.color_cycle <- factor(column_numbers %% n_colors)

  ggplot(long_ux) +
    aes(
      x = .data[[x_label]],
      y = .data$value,
      color = .data$.color_cycle
    ) +
    geom_line(
      aes(group = .data$.column)
    ) +
    guides(color = FALSE) +
    scale_color_manual(
      values = unname(grDevices::palette.colors(n_colors, palette = "R4"))
    ) +
    labs(title = rlang::expr_label(substitute(x)))
}

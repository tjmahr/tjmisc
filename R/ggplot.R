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

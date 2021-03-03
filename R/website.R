
#' Create a Jekyll draft post
#'
#' This is the function I use to create new posts for my website.
#'
#' @param slug A "slug" to use for the post. Should be a string consisting of
#'   `"hypen-separated-content-words`. Defaults to `NULL` in which case a random
#'   slug is created.
#' @param date Date string to use for the post. Default to `NULL` for the
#'   current date `format(Sys.Date())`.
#' @param dir_drafts Relative path to the folder to store the drafts. Defaults
#'   to `"./_R/_drafts`.
#' @param open Whether to open the file for editing when using RStudio. Defaults
#'   to `TRUE`.
#' @return The path to the created file is invisibly returned.
#' @export
jekyll_create_rmd_draft <- function(slug = NULL, date = NULL, dir_drafts = "./_R/_drafts", open = TRUE) {
  # generate random adjective-animal string as placeholder for slug
  if (is.null(slug)) slug <- ids::adjective_animal(1, 1, style = "kebab")
  if (is.null(date)) date <- format(Sys.Date())

  template_path <- find_template("draft.Rmd")
  draft_data <- list(date = date)
  draft_boilerplate <- render_template(template_path, draft_data)

  out_file <- sprintf("%s-%s.Rmd", draft_data$date, slug)
  out_path <- file.path(dir_drafts, out_file)

  message("Creating file: ", out_path)
  writeLines(draft_boilerplate, out_path)

  if (open && rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile(out_path)
  }

  invisible(out_path)
}


# Technique lifted from devtools/usethis
render_template <- function(template_path, data = list()) {
  template <- readLines(template_path)
  whisker::whisker.render(template, data)
}


find_template <- function(template_name) {
  system.file("templates", template_name, package = "tjmisc")
}

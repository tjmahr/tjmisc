#' Count words in an Rmarkdown file
#'
#' These functions strips away code and non-prose elements before counting words.
#'
#' @param path path to an Rmarkdown file
#' @param lines a character vector of text (from an Rmarkdown file)
#' @return a data-frame with the counts of word, characters in words, and
#'   whitespace characters. `simplify_rmd_lines()` returns a character vector of
#'   simplified Rmarkdown lines.
#' @rdname count_words_in_rmd_file
#' @export
#'
#' @details The helper function `simplify_rmd_lines()` strips down an Rmarkdown
#'   file so that dubious things do not contribute to the word count. It does
#'   the following.
#'
#' 1. Remove all lines that fall between a pair of \verb{````} lines. (These are
#'    used sometimes to show verbatim text from blocks with three tick marks).
#' 2. Remove all lines that fall between a pair of \verb{```} lines.
#' 3. Lines that end with \verb{`r} are merged with the following line.
#' 4. Inline code spans are replaced with a single word `` (`code`) ``.
#' 5. Single-line HTML comments are deleted.
#'
#' These steps are very ad hoc, updated and expanded as I run into new things
#' that need to be excluded from my word counts. Let's not pretend that this
#' thing is at all comprehensive.
#'
#' The word-count is computed by [stringi::stri_stats_latex()].
count_words_in_rmd_file <- function(path) {
  readr::read_lines(path) %>%
    count_words_in_rmd_lines()
}

#' @rdname count_words_in_rmd_file
#' @export
count_words_in_rmd_lines <- function(lines) {
  simplified <- simplify_rmd_lines(lines)

  wc <- stringi::stri_stats_latex(simplified)
  wc[c( "Words", "CharsWord", "CharsWhite")] %>%
    as.list() %>%
    tibble::as_tibble()
}

#' @rdname count_words_in_rmd_file
#' @export
simplify_rmd_lines <- function(lines) {
  lines %>%
    drop_which_between("^````") %>%
    drop_which_between("^```") %>%
    unwrap_dangling_inline_code() %>%
    erase_inline_code() %>%
    erase_html_comments()
}



#' Which lines fall in between a delimeter pattern
#'
#' @param string a character vector
#' @param pattern a regular expression pattern to look for
#' @return the lines that are contained between pairs of delimiter patterns
#' @export
#' @examples
#' string <- "
#' ```{r}
#' # some code
#' ```
#'
#' Here is more code.
#'
#' ```markdown
#' **bold!**
#' ```
#' "
#'
#' lines <- unlist(strsplit(string, "\n"))
#' str_which_between(lines, "^```")
str_which_between <- function(string, pattern) {
  hits <- stringr::str_which(string, pattern)
  if (length(hits) %% 2 == 1) {
    w <- glue::glue(
      'Odd number of delimiter ("{pattern}") matches found. Ignoring last one.')
    rlang::warn(w)
    hits <- hits[-length(hits)]
  }

  purrr::map2(odd_elements(hits), even_elements(hits), seq) %>%
    purrr::flatten_int()
}



drop_which_between <- function(string, pattern) {
  drop(string, str_which_between(string, pattern))
}

drop <- function(xs, is) {
  if (length(is) == 0) xs else xs[-is]
}



erase_inline_code <- function(lines, replacement = "(`code`)") {
  re_inline_code <- "(`r)( )([^`]+`)"
  stringr::str_replace_all(lines, re_inline_code, replacement)
}

erase_html_comments <- function(lines) {
  stringr::str_replace_all(lines, "<--.*-->", "")
}



# Fix cases where an inline code chunk is split across lines
unwrap_dangling_inline_code <- function(lines) {
  dangled <- stringr::str_which(lines, "`r\\s*$")
  if (length(dangled) != 0) {
    dangled_line <- lines[dangled[1]]
    next_line <- lines[dangled[1] + 1]
    fixed_line <- paste(dangled_line, next_line, sep = " ")
    lines[dangled[1]] <- fixed_line
    lines <- drop(lines, dangled[1] + 1)
    lines <- unwrap_dangling_inline_code(lines)
  }
  lines
}



odd_elements <- function(xs) xs[seq_along(xs) %% 2 == 1]
even_elements <- function(xs) xs[seq_along(xs) %% 2 == 0]

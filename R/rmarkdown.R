# odd_elements <- function(xs) xs[seq_along(xs) %% 2 == 1]
# even_elements <- function(xs) xs[seq_along(xs) %% 2 == 0]
#
# library(stringr)
#
# path <- "https://raw.githubusercontent.com/tjmahr/dissertation/master/12_aim1_notebook.Rmd"
# path <- "https://raw.githubusercontent.com/tjmahr/dissertation/master/00_scratch.Rmd"
# lines <- readLines(path)
#
#
#
#
# purrr::pluck(hits, odd_elements)
# purrr::pluck(hits, even_elements)
#
#
# str_which_lines_between <- function(string, pattern) {
#   hits <- str_which(string, pattern)
#   if (length(hits) %% 2 == 1) hits <- hits[-length(hits)]
#
#   purrr::map2(odd_elements(hits), even_elements(hits), seq) %>%
#     purrr::flatten_int()
# }
#
# drop <- function(xs, is) {
#   xs[-is]
# }
#
# between_fours <- str_which_lines_between(lines, "^````")
# lines <- drop(lines, between_fours)
# between_threes <- str_which_lines_between(lines, "^```")
# lines <- drop(lines, between_threes)
#
#
#  find_pair(lines, "^````")
#
# code <- purrr::map2(
#   str_which(lines, "^````."),
#   str_which(lines, "^````$"), seq) %>%
#   purrr::flatten_int()
#
# lines[-code] %>%
#   stringi::stri_stats_latex() %>%
#   getElement("Words")
#
#
# lines[-code] %>% stringi::stri_count_words() %>% sum()
#
# lines %>% stringi::stri_count_words() %>% sum
# start_of_appendix <-  all_lines %>%
#   str_detect("^Appendix: Model Summaries$") %>%
#   which
#
# start_of_appendix <- ifelse(length(start_of_appendix) == 0,
#                             length(all_lines), start_of_appendix)
#
# wordcount_rmd <- function(path) {
#
# }
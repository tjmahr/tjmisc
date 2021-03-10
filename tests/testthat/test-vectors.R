context("test-vectors.R")

test_that("is_same_as_last() finds repeated values", {
  c(1, 1, 2, 2, 1) %>%
    is_same_as_last() %>%
    expect_equal(c(FALSE, TRUE, FALSE, TRUE, FALSE))

  c("a", "a", "a", NA, "b", "b", "c", NA, NA) %>%
    is_same_as_last() %>%
    expect_equal(c(FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE))
})

test_that("replace_if_same_as_last() replaces repeated values", {
  c(1, 1, 2, 2, 1) %>%
    replace_if_same_as_last(0) %>%
    expect_equal(c(1, 0, 2, 0, 1))

  c("a", "a", "a", NA, "b", "b", "c", NA, NA) %>%
    replace_if_same_as_last("") %>%
    expect_equal(c("a", "", "", NA, "b", "", "c", NA, ""))
})


test_that("fct_format() works", {
  f <- factor(c("A", "B", "B", "C", "C", "C", "D"))

  expect_equal(
    f %>% fct_add_counts() %>% levels(),
    c("A (1)", "B (2)", "C (3)", "D (1)")
  )

  expect_equal(
    f %>% fct_add_counts(first_fmt = "Level {levels} ({counts})") %>% levels(),
    c("Level A (1)", "B (2)", "C (3)", "D (1)")
  )

  expect_equal(
    f %>% fct_glue_labels(first_fmt = "Level {levels} ({counts})") %>% levels(),
    c("Level A (1)", "B", "C", "D")
  )
  expect_equal(
    f %>% fct_glue_labels() %>% levels(),
    f %>% levels()
  )
})


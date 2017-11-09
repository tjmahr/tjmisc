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
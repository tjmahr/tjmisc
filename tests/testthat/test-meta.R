context("custom expectations")

test_that("expect_nrow() checks number of rows", {
  first_0 <- dplyr::slice(iris, 0)
  first_1 <- dplyr::slice(iris, 1)
  first_2 <- dplyr::slice(iris, 1:2)

  expect_failure(expect_nrow(first_2, 0), "has 2 rows, not 0 rows")
  expect_failure(expect_nrow(first_2, 1), "has 2 rows, not 1 row")
  expect_failure(expect_nrow(first_1, 2), "has 1 row, not 2 rows")

  expect_success(expect_nrow(first_0, 0))
  expect_success(expect_nrow(first_1, 1))
  expect_success(expect_nrow(first_2, 2))
})

test_that("expect_nrow() validates input", {
  expect_error(expect_nrow(iris, "1"), "numeric")
  expect_error(expect_nrow(iris, 1:2), "length")
  expect_error(expect_nrow(1:10, 1), "does not have rows")
})










context("stats tidiers")

test_that("tidy_quantile() returns quantiles", {
  qs <- quantile(iris$Sepal.Length, probs = c(.1, .2, .3))
  results <- tidy_quantile(iris, Sepal.Length, probs = c(.1, .2, .3))

  expect_equal(unname(qs), results$Sepal.Length)
  expect_equal(names(qs), results$quantile)

  # Try another column for good measure
  qs <- quantile(iris$Petal.Width, seq(0, 1, 0.25))
  results <- tidy_quantile(iris, Petal.Width, seq(0, 1, 0.25))

  expect_equal(unname(qs), results$Petal.Width)
  expect_equal(names(qs), results$quantile)
})

test_that("tidy_quantile() respects grouped data", {
  by_hand <- function(xs, splits, probs) {
    qs_list <- xs %>% split(splits) %>% lapply(quantile, probs)
    list(
      names = qs_list %>% lapply(names) %>% unlist(use.names = FALSE),
      values = unlist(qs_list, use.names = FALSE)
    )
  }

  # One group variable
  results <- iris %>%
    dplyr::group_by(Species) %>%
    tidy_quantile(Sepal.Length, probs = c(.1, .2, .3))

  qs <- by_hand(iris$Sepal.Length, iris$Species, probs = c(.1, .2, .3))

  expect_equal(qs$values, results$Sepal.Length)
  expect_equal(qs$names, results$quantile)

  # Two grouping variables
  results2 <- mtcars %>%
    dplyr::group_by(cyl, am) %>%
    tidy_quantile(mpg, seq(0, 1, 0.25))

  qs2 <- by_hand(mtcars$mpg, interaction(mtcars$am, mtcars$cyl),
                 probs = seq(0, 1, 0.25))

  expect_equal(qs2$values, results2$mpg)
  expect_equal(qs2$names, results2$quantile)
})

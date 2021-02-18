context("stats tidiers")

test_that("tidy_quantile() returns quantiles", {
  qs <- quantile(mtcars$mpg, probs = c(.1, .2, .3))
  results <- tidy_quantile(mtcars, mpg, probs = c(.1, .2, .3))

  expect_equal(unname(qs), results$mpg)
  expect_equal(names(qs), results$quantile)

  # Try another column for good measure
  qs <- quantile(mtcars$hp , seq(0, 1, 0.25))
  results <- tidy_quantile(mtcars, hp , seq(0, 1, 0.25))

  expect_equal(unname(qs), results$hp)
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
  results <- mtcars %>%
    dplyr::group_by(cyl) %>%
    tidy_quantile(mpg, probs = c(.1, .2, .3))

  qs <- by_hand(mtcars$mpg, mtcars$cyl, probs = c(.1, .2, .3))

  expect_equal(qs$values, results$mpg)
  expect_equal(qs$names, results$quantile)

  # Two grouping variables
  results2 <- mtcars %>%
    dplyr::group_by(cyl, am) %>%
    tidy_quantile(mpg, seq(0, 1, 0.25))

  qs2 <- by_hand(
    mtcars$mpg,
    interaction(mtcars$am, mtcars$cyl),
    probs = seq(0, 1, 0.25)
  )

  expect_equal(qs2$values, results2$mpg)
  expect_equal(qs2$names, results2$quantile)
})


test_that("tidy_correlation() calculates correlations", {
  df <- mtcars[c("mpg", "disp", "hp", "wt", "cyl")]
  ncors <- sum(lower.tri(cor(df[-5])))

  results <- tidy_correlation(df, -cyl)

  cor_row <- function(x, y) cor(df[[x]], df[[y]]) %>% round(4)
  cors <- Map(cor_row, results$column1, results$column2) %>%
    unlist(use.names = FALSE)

  expect_equal(results$estimate, cors)
  expect_nrow(results, ncors)
})


test_that("tidy_correlation() respects grouped data", {
  df <- mtcars[c("mpg", "disp", "hp", "wt", "cyl")]
  ncors <- sum(lower.tri(cor(df[-5])))

  results <- df %>%
    dplyr::group_by(cyl) %>%
    tidy_correlation(-cyl)

  cor_row <- function(s, x, y) {
    these <- mtcars[mtcars$cyl == s, ]
    cor(these[[x]], these[[y]]) %>% round(4)
  }

  cors <- Map(cor_row, results$cyl, results$column1, results$column2) %>%
    unlist(use.names = FALSE)

  expect_equal(results$estimate, cors)

  # check that right number of correlations are calculated in each group
  expect_nrow(results, ncors * 3)
})

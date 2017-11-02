context("data munging helpers")

sample_data <- tibble::tibble(
  letter = rep(letters, 5),
  color = rep(c("red", "green", "yellow", "orange", "blue"), 26),
  value = rnorm(26 * 5)
)

test_that("sample_n_of() samples from n groups", {
  four_letters <- sample_n_of(sample_data, 4, letter)
  two_colors <- sample_n_of(sample_data, 2, color)
  three_letter_colors <- sample_n_of(sample_data, 3, letter, color)

  # four letters in five colors
  four_letters %>%
    expect_nrow(4 * 5) %>%
    dplyr::distinct(letter) %>%
    expect_nrow(4)

  # two colors in 26 letters
  two_colors %>%
    expect_nrow(2 * 26) %>%
    dplyr::distinct(color) %>%
    expect_nrow(2)

  # color-letter pairs are unique
  three_letter_colors %>%
    expect_nrow(3) %>%
    dplyr::distinct(letter, color) %>%
    expect_nrow(3)
})

test_that("sample_n_of() warns about sample size", {
  expect_warning(sample_n_of(sample_data, 40, letter),
                 regexp = "Sample size.+ is larger than")
})

test_that("sample_n_of() samples n rows if no groups given", {
  sample_n_of(sample_data, 10) %>%
    nrow() %>%
    expect_equal(10)

  sample_n_of(sample_data, 0) %>%
    nrow() %>%
    expect_equal(0)
})

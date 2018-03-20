context("rmarkdown helpers")

test_that("str_which_between() helps find lines in code blocks", {
  lines <- c(
    "```{r}",       # 1
    "# some code",  # 2
    "```",          # 3
    "",
    "Here is more code.",
    "",
    "```markdown",  # 7
    "**bold!**",    # 8
    "```")          # 9

  expect_equal(str_which_between(lines, "^```"), c(1:3, 7:9))
})

test_that("str_which_between() warns for partial matches", {
  lines <- c(
    "```{r}",       # 1
    "# some code",  # 2
    "```",          # 3
    "",
    "Here is more code.",
    "",
    "```markdown",  # 7
    "**bold!**",    # 8
    "```",          # 9
    "",
    "```")          # 11 (ignored)

  expect_warning(str_which_between(lines, "^```"))

  matches <- suppressWarnings(str_which_between(lines, "^```"))
  expect_equal(matches, c(1:3, 7:9))
})

test_that("simplify_rmd_lines() handles html comments", {
  lines <- c(
    "```{r}",
    "```",
    "",
    "Here is more code.",
    "",
    "1. This is text",
    "<!-- This is a comment -->",
    "2. This is text",
    "<!-- This is a comment -->",
    "3. This is text")

  expected <- c(
    "",
    "Here is more code.",
    "",
    "1. This is text",
    "",
    "2. This is text",
    "",
    "3. This is text")

  expect_equal(simplify_rmd_lines(lines), expected)
})

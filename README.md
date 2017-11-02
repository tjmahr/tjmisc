
<!-- README.md is generated from README.Rmd. Please edit that file -->
tjmisc
======

The goal of tjmisc is to gather miscellaneous helper functions, mostly for use in [my dissertation](https://github.com/tjmahr/dissertation).

Apologies in advance. I think "misc" packages are kind of bad because packages should be focused on specific problems: for example, my helper packages for [working on polynomials](https://github.com/tjmahr/polypoly), [printing numbers](https://github.com/tjmahr/printy) or [tidying MCMC samples](https://github.com/tjmahr/tristan). Having modular code snapping together like Lego blocks is better than a grab-bag of functions, it's true, but using `library(helpers)` is much, much better than using `source("helpers.R")`. So here we are... in the grab-bag.

Examples
--------

`sample_n_of()` is like dplyr's `sample_n()` but it samples groups.

``` r
library(dplyr, warn.conflicts = FALSE)
#> Warning: package 'dplyr' was built under R version 3.4.2
library(tjmisc)
set.seed(11022017)

data <- tibble::tibble(
  day = 1:10 %>% rep(10) %>% sort(),
  id  = 1:10 %>% rep(10),
  block = letters[1:5] %>% rep(10) %>% sort() %>% rep(2),
  value = rnorm(100) %>% round(2))

# data from 2 days
sample_n_of(data, 2, day)
#> # A tibble: 20 x 4
#>      day    id block value
#>    <int> <int> <chr> <dbl>
#>  1     8     1     c  0.87
#>  2     8     2     c  0.31
#>  3     8     3     c -1.73
#>  4     8     4     c -1.49
#>  5     8     5     c  0.38
#>  6     8     6     c  0.20
#>  7     8     7     c -1.87
#>  8     8     8     c  2.02
#>  9     8     9     c  1.36
#> 10     8    10     c  0.94
#> 11    10     1     e  0.64
#> 12    10     2     e -0.76
#> 13    10     3     e -1.68
#> 14    10     4     e -1.86
#> 15    10     5     e  1.02
#> 16    10     6     e  0.12
#> 17    10     7     e  0.35
#> 18    10     8     e  0.43
#> 19    10     9     e -0.43
#> 20    10    10     e -1.71

# data from 1 id
sample_n_of(data, 1, id)
#> # A tibble: 10 x 4
#>      day    id block value
#>    <int> <int> <chr> <dbl>
#>  1     1     2     a -0.01
#>  2     2     2     b  1.28
#>  3     3     2     c -0.29
#>  4     4     2     d  0.49
#>  5     5     2     e -0.39
#>  6     6     2     a  0.22
#>  7     7     2     b  0.30
#>  8     8     2     c  0.31
#>  9     9     2     d -1.11
#> 10    10     2     e -0.76

# data from 2 block-id pairs
sample_n_of(data, 2, block, id)
#> # A tibble: 4 x 4
#>     day    id block value
#>   <int> <int> <chr> <dbl>
#> 1     1     5     a  0.72
#> 2     4     9     d -0.31
#> 3     6     5     a -0.21
#> 4     9     9     d  0.92
```

`tidy_quantile()` returns a dataframe with quantiles for a given variable. I like to use it to select values for plotting model predictions.

``` r
iris %>% 
  tidy_quantile(Petal.Length)
#> # A tibble: 5 x 2
#>   quantile Petal.Length
#>      <chr>        <dbl>
#> 1      10%         1.40
#> 2      30%         1.70
#> 3      50%         4.35
#> 4      70%         5.00
#> 5      90%         5.80

iris %>% 
  group_by(Species) %>% 
  tidy_quantile(Petal.Length)
#> # A tibble: 15 x 3
#>       Species quantile Petal.Length
#>        <fctr>    <chr>        <dbl>
#>  1     setosa      10%         1.30
#>  2     setosa      30%         1.40
#>  3     setosa      50%         1.50
#>  4     setosa      70%         1.50
#>  5     setosa      90%         1.70
#>  6 versicolor      10%         3.59
#>  7 versicolor      30%         4.00
#>  8 versicolor      50%         4.35
#>  9 versicolor      70%         4.50
#> 10 versicolor      90%         4.80
#> 11  virginica      10%         4.90
#> 12  virginica      30%         5.10
#> 13  virginica      50%         5.55
#> 14  virginica      70%         5.80
#> 15  virginica      90%         6.31
```

`ggpreview()` is like ggplot2's `ggsave()` but it saves an image to a temporary file and then opens it in the system viewer. If you've ever found yourself in a loop of saving a plot, leaving RStudio to doubleclick the file, sighing, going back to RStudio, tweaking the height or width or plot theme, ever so slowly spiraling in on your desired plot, then `ggpreview()` is for you.

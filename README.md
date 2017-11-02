
<!-- README.md is generated from README.Rmd. Please edit that file -->
tjmisc
======

The goal of tjmisc is to gather miscellaneous helper functions, mostly for use in [my dissertation](https://github.com/tjmahr/dissertation).

Apologies in advance. I think "misc" packages are kind of bad because packages should be focused on specific problems: for example, my helper packages for [working on polynomials](https://github.com/tjmahr/polypoly), [printing numbers](https://github.com/tjmahr/printy) or [tidying MCMC samples](https://github.com/tjmahr/tristan). Having modular code snapping together like Lego blocks is better than a grab-bag of functions, it's true, but using `library(helpers)` is much, much better than using `source("helpers.R")`. So here we are... in the grab-bag.

Installation
------------

You can install the tjmisc from github with:

``` r
# install.packages("devtools")
devtools::install_github("tjmahr/tjmisc")
```

Examples
--------

### Sample groups of data

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

# data from 3 days
sample_n_of(data, 3, day)
#> # A tibble: 30 x 4
#>      day    id block value
#>    <int> <int> <chr> <dbl>
#>  1     2     1     b  1.01
#>  2     2     2     b  1.28
#>  3     2     3     b -1.40
#>  4     2     4     b -0.46
#>  5     2     5     b  0.98
#>  6     2     6     b  2.05
#>  7     2     7     b  0.11
#>  8     2     8     b  0.15
#>  9     2     9     b  0.18
#> 10     2    10     b -1.54
#> # ... with 20 more rows

# data from 1 id
sample_n_of(data, 1, id)
#> # A tibble: 10 x 4
#>      day    id block value
#>    <int> <int> <chr> <dbl>
#>  1     1     1     a -0.51
#>  2     2     1     b  1.01
#>  3     3     1     c -0.06
#>  4     4     1     d  1.14
#>  5     5     1     e  0.47
#>  6     6     1     a  0.26
#>  7     7     1     b  1.15
#>  8     8     1     c  0.87
#>  9     9     1     d  0.69
#> 10    10     1     e  0.64

# data from 2 block-id pairs
sample_n_of(data, 2, block, id)
#> # A tibble: 4 x 4
#>     day    id block value
#>   <int> <int> <chr> <dbl>
#> 1     2     2     b  1.28
#> 2     4    10     d -2.81
#> 3     7     2     b  0.30
#> 4     9    10     d -0.64
```

### Tidy quantiles

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

### Tidy correlations

`tidy_correlation()` calculates correlations between pairs of selected dataframe columns. It accepts `dplyr::select()` selection semantics, and it respects grouped dataframes.

``` r
tidy_correlation(iris, -Species)
#> # A tibble: 6 x 5
#>        column1      column2 estimate     n p.value
#>          <chr>        <chr>    <dbl> <dbl>   <dbl>
#> 1 Sepal.Length  Sepal.Width  -0.1176   150  0.1519
#> 2 Sepal.Length Petal.Length   0.8718   150  0.0000
#> 3  Sepal.Width Petal.Length  -0.4284   150  0.0000
#> 4 Sepal.Length  Petal.Width   0.8179   150  0.0000
#> 5  Sepal.Width  Petal.Width  -0.3661   150  0.0000
#> 6 Petal.Length  Petal.Width   0.9629   150  0.0000

iris %>%
  dplyr::group_by(Species) %>%
  tidy_correlation(dplyr::starts_with("Petal"))
#> # A tibble: 3 x 6
#>      Species      column1     column2 estimate     n p.value
#>       <fctr>        <chr>       <chr>    <dbl> <dbl>   <dbl>
#> 1     setosa Petal.Length Petal.Width   0.3316    50  0.0186
#> 2 versicolor Petal.Length Petal.Width   0.7867    50  0.0000
#> 3  virginica Petal.Length Petal.Width   0.3221    50  0.0225
```

<!-- ### Pairwise comparisons -->
<!-- `compare_pairs()` compares all pairs of values among levels of a categorical -->
<!-- variable. Hmmm, that sounds confusing. Here's an example. We compute the -->
<!-- difference in average score between each pair of workers. -->
<!-- ```{r} -->
<!-- to_compare <- nlme::Machines %>% -->
<!--   group_by(Worker) %>% -->
<!--   summarise(avg_score = mean(score)) %>% -->
<!--   print() -->
<!-- to_compare %>% -->
<!--   compare_pairs(Worker, avg_score) %>% -->
<!--   rename(difference = value) %>% -->
<!--   mutate_if(is.numeric, round, 1) -->
<!-- ``` -->
<!-- I use it to compute posterior differences in Bayesian models. For example, let's -->
<!-- fit a Bayesian model of average sepal length for each species in `iris`. -->
<!-- ```{r, results = "hide"} -->
<!-- library(rstanarm) -->
<!-- m <- stan_glm( -->
<!--   Sepal.Length ~ Species - 1, -->
<!--   iris, -->
<!--   family = gaussian, -->
<!--   prior = normal(0, 1), -->
<!--   prior_intercept = normal(0, 1)) -->
<!-- ``` -->
<!-- Now, we have a posterior distributions of species means. -->
<!-- ```{r} -->
<!-- newdata <- data.frame(Species = unique(iris$Species)) -->
<!-- p_means <- posterior_linpred(m, newdata = newdata) %>% -->
<!--   as.data.frame() %>% -->
<!--   tibble::as_tibble() %>% -->
<!--   setNames(newdata$Species) %>% -->
<!--   tibble::rowid_to_column("draw") %>% -->
<!--   tidyr::gather(species, mean, -draw) %>% -->
<!--   print() -->
<!-- ``` -->
<!-- For each posterior sample, we can compute pairwise differences of means. -->
<!-- ```{r pairs, fig.width = 4, fig.height = 2.5} -->
<!-- pair_diffs <- compare_pairs(data, species, mean) %>% -->
<!--   print() -->
<!-- library(ggplot2) -->
<!-- ggplot(pair_diffs) + -->
<!--   aes(x = pair, y = value) + -->
<!--   stat_summary(fun.data = median_hilow, geom = "linerange") + -->
<!--   stat_summary(fun.data = median_hilow, fun.args = list(conf.int = .8), -->
<!--                size = 2, geom = "linerange") + -->
<!--   stat_summary(fun.y = median, size = 5, shape = 3, geom = "point") + -->
<!--   labs(x = NULL, y = "Difference in posterior means") + -->
<!--   coord_flip() -->
<!-- ``` -->
### Et cetera

`ggpreview()` is like ggplot2's `ggsave()` but it saves an image to a temporary file and then opens it in the system viewer. If you've ever found yourself in a loop of saving a plot, leaving RStudio to doubleclick the file, sighing, going back to RStudio, tweaking the height or width or plot theme, ever so slowly spiraling in on your desired plot, then `ggpreview()` is for you.

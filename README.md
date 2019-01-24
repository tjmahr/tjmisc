
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tjmisc

[![Travis build
status](https://travis-ci.org/tjmahr/tjmisc.svg?branch=master)](https://travis-ci.org/tjmahr/tjmisc)

The goal of tjmisc is to gather miscellaneous helper functions, mostly
for use in [my dissertation](https://github.com/tjmahr/dissertation).

Apologies in advance. I think “misc” packages are kind of bad because
packages should be focused on specific problems: for example, my helper
packages for [working on
polynomials](https://github.com/tjmahr/polypoly), [printing
numbers](https://github.com/tjmahr/printy) or [tidying MCMC
samples](https://github.com/tjmahr/tristan). Having modular code
snapping together like Lego blocks is better than a grab-bag of
functions, it’s true, but using `library(helpers)` is much, much better
than using `source("helpers.R")`. So here we are… in the grab-bag.

## Installation

You can install the tjmisc from github with:

``` r
# install.packages("devtools")
devtools::install_github("tjmahr/tjmisc")
```

## Examples

### Sample groups of data

`sample_n_of()` is like dplyr’s `sample_n()` but it samples groups.

``` r
library(dplyr, warn.conflicts = FALSE)
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
#>  1     2     1 b      1.01
#>  2     2     2 b      1.28
#>  3     2     3 b     -1.4 
#>  4     2     4 b     -0.46
#>  5     2     5 b      0.98
#>  6     2     6 b      2.05
#>  7     2     7 b      0.11
#>  8     2     8 b      0.15
#>  9     2     9 b      0.18
#> 10     2    10 b     -1.54
#> # ... with 20 more rows

# data from 1 id
sample_n_of(data, 1, id)
#> # A tibble: 10 x 4
#>      day    id block value
#>    <int> <int> <chr> <dbl>
#>  1     1     1 a     -0.51
#>  2     2     1 b      1.01
#>  3     3     1 c     -0.06
#>  4     4     1 d      1.14
#>  5     5     1 e      0.47
#>  6     6     1 a      0.26
#>  7     7     1 b      1.15
#>  8     8     1 c      0.87
#>  9     9     1 d      0.69
#> 10    10     1 e      0.64

# data from 2 block-id pairs
sample_n_of(data, 2, block, id)
#> # A tibble: 4 x 4
#>     day    id block value
#>   <int> <int> <chr> <dbl>
#> 1     2     2 b      1.28
#> 2     4    10 d     -2.81
#> 3     7     2 b      0.3 
#> 4     9    10 d     -0.64
```

### Tidy quantiles

`tidy_quantile()` returns a dataframe with quantiles for a given
variable. I like to use it to select values for plotting model
predictions.

``` r
iris %>% 
  tidy_quantile(Petal.Length)
#> # A tibble: 5 x 2
#>   quantile Petal.Length
#>   <chr>           <dbl>
#> 1 10%              1.4 
#> 2 30%              1.7 
#> 3 50%              4.35
#> 4 70%              5   
#> 5 90%              5.8

iris %>% 
  group_by(Species) %>% 
  tidy_quantile(Petal.Length)
#> # A tibble: 15 x 3
#>    Species    quantile Petal.Length
#>    <fct>      <chr>           <dbl>
#>  1 setosa     10%              1.3 
#>  2 setosa     30%              1.4 
#>  3 setosa     50%              1.5 
#>  4 setosa     70%              1.5 
#>  5 setosa     90%              1.7 
#>  6 versicolor 10%              3.59
#>  7 versicolor 30%              4   
#>  8 versicolor 50%              4.35
#>  9 versicolor 70%              4.5 
#> 10 versicolor 90%              4.8 
#> 11 virginica  10%              4.9 
#> 12 virginica  30%              5.1 
#> 13 virginica  50%              5.55
#> 14 virginica  70%              5.8 
#> 15 virginica  90%              6.31
```

### Tidy correlations

`tidy_correlation()` calculates correlations between pairs of selected
dataframe columns. It accepts `dplyr::select()` selection semantics, and
it respects grouped dataframes.

``` r
tidy_correlation(iris, -Species)
#> # A tibble: 6 x 5
#>   column1      column2      estimate     n p.value
#>   <chr>        <chr>           <dbl> <dbl>   <dbl>
#> 1 Sepal.Length Sepal.Width    -0.118   150   0.152
#> 2 Sepal.Length Petal.Length    0.872   150   0    
#> 3 Sepal.Width  Petal.Length   -0.428   150   0    
#> 4 Sepal.Length Petal.Width     0.818   150   0    
#> 5 Sepal.Width  Petal.Width    -0.366   150   0    
#> 6 Petal.Length Petal.Width     0.963   150   0

iris %>%
  dplyr::group_by(Species) %>%
  tidy_correlation(dplyr::starts_with("Petal"))
#> # A tibble: 3 x 6
#>   Species    column1      column2     estimate     n p.value
#>   <fct>      <chr>        <chr>          <dbl> <dbl>   <dbl>
#> 1 setosa     Petal.Length Petal.Width    0.332    50  0.0186
#> 2 versicolor Petal.Length Petal.Width    0.787    50  0     
#> 3 virginica  Petal.Length Petal.Width    0.322    50  0.0225
```

### Pairwise comparisons

`compare_pairs()` compares all pairs of values among levels of a
categorical variable. Hmmm, that sounds confusing. Here’s an example. We
compute the difference in average score between each pair of workers.

``` r
to_compare <- nlme::Machines %>%
  group_by(Worker) %>%
  summarise(avg_score = mean(score)) %>%
  print()
#> # A tibble: 6 x 2
#>   Worker avg_score
#>   <ord>      <dbl>
#> 1 6           50.6
#> 2 2           58.0
#> 3 4           59.6
#> 4 1           60.9
#> 5 3           66.1
#> 6 5           62.7

to_compare %>%
  compare_pairs(Worker, avg_score) %>%
  rename(difference = value) %>%
  mutate_if(is.numeric, round, 1)
#> # A tibble: 15 x 2
#>    pair  difference
#>    <fct>      <dbl>
#>  1 1-6         10.3
#>  2 1-4          1.3
#>  3 1-2          2.9
#>  4 2-6          7.4
#>  5 3-6         15.5
#>  6 3-4          6.5
#>  7 3-2          8.1
#>  8 3-1          5.2
#>  9 4-6          9  
#> 10 4-2          1.6
#> 11 5-6         12.1
#> 12 5-4          3.1
#> 13 5-3         -3.4
#> 14 5-2          4.7
#> 15 5-1          1.8
```

### Et cetera

`ggpreview()` is like ggplot2’s `ggsave()` but it saves an image to a
temporary file and then opens it in the system viewer. If you’ve ever
found yourself in a loop of saving a plot, leaving RStudio to
doubleclick the file, sighing, going back to RStudio, tweaking the
height or width or plot theme, ever so slowly spiraling in on your
desired plot, then `ggpreview()` is for you.

`seq_along_rows()` saves a few keystrokes in for-loops that iterate over
dataframe rows.

``` r
cars %>% head(5) %>% seq_along_rows()
#> [1] 1 2 3 4 5
cars %>% head(0) %>% seq_along_rows()
#> integer(0)
```

`is_same_as_last` and `replace_if_same_as_last()` are helpers for
formatting tables. I use them to replace repeating values in a text
column with blanks.

``` r
mtcars %>% 
  tibble::rownames_to_column("name") %>% 
  slice(1:10) %>% 
  select(cyl, name, mpg) %>% 
  arrange(cyl, mpg) %>% 
  mutate_at(c("cyl"), replace_if_same_as_last, "") %>% 
  knitr::kable()
```

| cyl | name              |  mpg |
| :-- | :---------------- | ---: |
| 4   | Datsun 710        | 22.8 |
|     | Merc 230          | 22.8 |
|     | Merc 240D         | 24.4 |
| 6   | Valiant           | 18.1 |
|     | Merc 280          | 19.2 |
|     | Mazda RX4         | 21.0 |
|     | Mazda RX4 Wag     | 21.0 |
|     | Hornet 4 Drive    | 21.4 |
| 8   | Duster 360        | 14.3 |
|     | Hornet Sportabout | 18.7 |

`fct_add_counts()` adds counts to a factor’s labels.

``` r
# Create a factor with some random counts
set.seed(20190124)
random_iris <- iris %>% 
  dplyr::sample_n(250, replace = TRUE)

table(random_iris$Species)
#> 
#>     setosa versicolor  virginica 
#>         84         74         92

# Updated factors
random_iris$Species %>% levels()
#> [1] "setosa"     "versicolor" "virginica"
random_iris$Species %>% fct_add_counts() %>% levels()
#> [1] "setosa (84)"     "versicolor (74)" "virginica (92)"
```

You can tweak the format for the first label. I like to use this for
plotting by stating the unit next to the first count.

``` r
random_iris$Species %>% 
  fct_add_counts(first_fmt = "{levels} ({counts} flowers)") %>% 
  levels()
#> [1] "setosa (84 flowers)" "versicolor (74)"     "virginica (92)"
```

## More involved demos

These are things that I would have used in the demo above but cut and
moved down here to keep that overview succinct.

### Comparing pairs of values over a posterior distribution

I wrote `compare_pairs()` to compute posterior differences in Bayesian
models. For the sake of example, let’s fit a Bayesian model of average
sepal length for each species in `iris`. We could get these estimates
more directly using the default dummy-coding of factors, but let’s
ignore that for now.

``` r
library(rstanarm)
#> Loading required package: Rcpp
#> rstanarm (Version 2.18.2, packaged: 2018-11-08 22:19:38 UTC)
#> - Do not expect the default priors to remain the same in future rstanarm versions.
#> Thus, R scripts should specify priors explicitly, even if they are just the defaults.
#> - For execution on a local, multicore CPU with excess RAM we recommend calling
#> options(mc.cores = parallel::detectCores())
#> - Plotting theme set to bayesplot::theme_default().
m <- stan_glm(
  Sepal.Length ~ Species - 1,
  iris,
  family = gaussian)
```

Now, we have a posterior distribution of species means.

``` r
newdata <- data.frame(Species = unique(iris$Species))

p_means <- posterior_linpred(m, newdata = newdata) %>%
  as.data.frame() %>%
  tibble::as_tibble() %>%
  setNames(newdata$Species) %>%
  tibble::rowid_to_column("draw") %>%
  tidyr::gather(species, mean, -draw) %>%
  print()
#> # A tibble: 12,000 x 3
#>     draw species  mean
#>    <int> <chr>   <dbl>
#>  1     1 setosa   4.98
#>  2     2 setosa   4.99
#>  3     3 setosa   4.95
#>  4     4 setosa   5.04
#>  5     5 setosa   5.01
#>  6     6 setosa   4.93
#>  7     7 setosa   5.09
#>  8     8 setosa   5.00
#>  9     9 setosa   5.08
#> 10    10 setosa   4.83
#> # ... with 11,990 more rows
```

For each posterior sample, we can compute pairwise differences of means
with `compare_means()`.

``` r
pair_diffs <- compare_pairs(p_means, species, mean) %>%
  print()
#> # A tibble: 12,000 x 3
#>     draw pair              value
#>    <int> <fct>             <dbl>
#>  1     1 versicolor-setosa 1.01 
#>  2     2 versicolor-setosa 0.979
#>  3     3 versicolor-setosa 0.939
#>  4     4 versicolor-setosa 0.934
#>  5     5 versicolor-setosa 0.956
#>  6     6 versicolor-setosa 1.00 
#>  7     7 versicolor-setosa 0.867
#>  8     8 versicolor-setosa 0.884
#>  9     9 versicolor-setosa 0.653
#> 10    10 versicolor-setosa 1.24 
#> # ... with 11,990 more rows

library(ggplot2)

ggplot(pair_diffs) +
  aes(x = pair, y = value) +
  stat_summary(fun.data = median_hilow, geom = "linerange") +
  stat_summary(fun.data = median_hilow, fun.args = list(conf.int = .8),
               size = 2, geom = "linerange") +
  stat_summary(fun.y = median, size = 5, shape = 3, geom = "point") +
  labs(x = NULL, y = "Difference in posterior means") +
  coord_flip()
```

![](man/figures/README-pairs-1.png)<!-- -->

…which should look like the effect ranges in the dummy-coded models.

``` r
m2 <- update(m, Sepal.Length ~ Species)
m3 <- update(m, Sepal.Length ~ Species, 
             data = iris %>% mutate(Species = forcats::fct_rev(Species)))
```

Give or take a few decimals of precision and give or take changes in
signs because of changes in who was subtracted from whom.

``` r
# setosa verus others
m2 %>% 
  posterior_interval(regex_pars = "Species") %>% 
  round(2)
#>                     5%  95%
#> Speciesversicolor 0.75 1.09
#> Speciesvirginica  1.41 1.74

# virginica versus others
m3 %>% 
  rstanarm::posterior_interval(regex_pars = "Species") %>% 
  round(2)
#>                      5%   95%
#> Speciesversicolor -0.82 -0.48
#> Speciessetosa     -1.75 -1.40

# differences from compare_pairs()
pair_diffs %>% 
  tidyr::spread(pair, value) %>% 
  select(-draw) %>% 
  as.matrix() %>% 
  posterior_interval() %>% 
  round(2)
#>                        5%  95%
#> versicolor-setosa    0.75 1.10
#> virginica-versicolor 0.48 0.82
#> virginica-setosa     1.41 1.75
```

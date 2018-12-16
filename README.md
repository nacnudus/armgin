
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/nacnudus/armgin.svg?branch=master)](https://travis-ci.org/nacnudus/armgin)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/nacnudus/armgin?branch=master&svg=true)](https://ci.appveyor.com/project/nacnudus/armgin)
[![Coverage
status](https://codecov.io/gh/nacnudus/armgin/branch/master/graph/badge.svg)](https://codecov.io/github/nacnudus/armgin?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/armgin)](https://cran.r-project.org/package=armgin)

# armgin

The armgin package summarises all combinations of grouping variables at
once. For example, vote counts by

    * voting place, ward, constituency, party, candidate
    * voting place, ward, constituency, party
    * voting place, ward, constituency
    * voting place, ward,
    * voting place

Or with `hierarchy = FALSE` and grouping by only voting place, ward and
constituency (for brevity)

    * voting place, ward, constituency
    
    * voting place, ward
    * voting place, constituency
    * ward, constituency
    
    * voting place
    * ward
    * constituency

Groups are defined as normal by `dplyr::group_by()` and then piped into
`margins()`.

``` r
library(dplyr)
library(armgin)

mtcars %>%
  group_by(cyl, gear, am) %>%
  margins(mpg = mean(mpg),
          hp = min(hp)) %>%
  print(n = Inf)
#> # A tibble: 21 x 5
#> # Groups:   cyl [3]
#>      cyl  gear    am   mpg    hp
#>    <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1     4    NA    NA  26.7    52
#>  2     6    NA    NA  19.7   105
#>  3     8    NA    NA  15.1   150
#>  4     4     3    NA  21.5    97
#>  5     4     4    NA  26.9    52
#>  6     4     5    NA  28.2    91
#>  7     6     3    NA  19.8   105
#>  8     6     4    NA  19.8   110
#>  9     6     5    NA  19.7   175
#> 10     8     3    NA  15.0   150
#> 11     8     5    NA  15.4   264
#> 12     4     3     0  21.5    97
#> 13     4     4     0  23.6    62
#> 14     4     4     1  28.0    52
#> 15     4     5     1  28.2    91
#> 16     6     3     0  19.8   105
#> 17     6     4     0  18.5   123
#> 18     6     4     1  21     110
#> 19     6     5     1  19.7   175
#> 20     8     3     0  15.0   150
#> 21     8     5     1  15.4   264
```

Output individual data frames with `bind = FALSE`.

``` r
mtcars %>%
  group_by(cyl, gear, am) %>%
  margins(mpg = mean(mpg),
          hp = min(hp),
          bind = FALSE)
#> [[1]]
#> # A tibble: 3 x 3
#> # Groups:   cyl [3]
#>     cyl   mpg    hp
#>   <dbl> <dbl> <dbl>
#> 1     4  26.7    52
#> 2     6  19.7   105
#> 3     8  15.1   150
#> 
#> [[2]]
#> # A tibble: 8 x 4
#> # Groups:   cyl, gear [8]
#>     cyl  gear   mpg    hp
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     4     3  21.5    97
#> 2     4     4  26.9    52
#> 3     4     5  28.2    91
#> 4     6     3  19.8   105
#> 5     6     4  19.8   110
#> 6     6     5  19.7   175
#> 7     8     3  15.0   150
#> 8     8     5  15.4   264
#> 
#> [[3]]
#> # A tibble: 10 x 5
#> # Groups:   cyl, gear, am [10]
#>      cyl  gear    am   mpg    hp
#>    <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1     4     3     0  21.5    97
#>  2     4     4     0  23.6    62
#>  3     4     4     1  28.0    52
#>  4     4     5     1  28.2    91
#>  5     6     3     0  19.8   105
#>  6     6     4     0  18.5   123
#>  7     6     4     1  21     110
#>  8     6     5     1  19.7   175
#>  9     8     3     0  15.0   150
#> 10     8     5     1  15.4   264
```

## Installation

You can install the development version from GitHub with devtools or
remotes.

``` r
install.packages("devtools")
devtools::install_github("nacnudus/armgin")
```

Please note that the ‘armgin’ project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.

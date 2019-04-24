
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

Or with `method = "combination"` and grouping by only voting place, ward
and constituency (for brevity)

    * voting place, ward, constituency
    
    * voting place, ward
    * voting place, constituency
    * ward, constituency
    
    * voting place
    * ward
    * constituency

Groups are defined as normal by `dplyr::group_by()` and then piped into
`armgin::margins()`.

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

## Motivating example

What are the salaries of various jobs, grades and professions in the
UK’s Joint Nature Conservation Committee?

``` r
library(armgin)

library(dplyr)
library(tidyr)
library(readr)

# organogram.csv is from "https://data.gov.uk/sites/default/files/organogram/joint-nature-conservation-committee/30/9/2018/20180930%20JNCC-junior.csv",

organogram <-
  read_csv("organogram.csv") %>%
  replace_na(list(Grade = "Other"))
#> Parsed with column specification:
#> cols(
#>   `Parent Department` = col_character(),
#>   Organisation = col_character(),
#>   Unit = col_character(),
#>   `Reporting Senior Post` = col_character(),
#>   Grade = col_character(),
#>   `Payscale Minimum (£)` = col_double(),
#>   `Payscale Maximum (£)` = col_double(),
#>   `Generic Job Title` = col_character(),
#>   `Number of Posts in FTE` = col_double(),
#>   `Professional/Occupational Group` = col_character()
#> )
```

It could be a hierarchy with the whole JNCC Organisation at the top,
then Grade within that, then Profession as the bottom grouping.

``` r
organogram  %>%
  group_by(Organisation, Grade, `Professional/Occupational Group`) %>%
  margins(min = min(`Payscale Minimum (£)`),
          max = max(`Payscale Maximum (£)`),
          fte = sum(`Number of Posts in FTE`)) %>%
  mutate_if(is.character, replace_na, "All") %>%
  print(n = Inf)
#> `mutate_if()` ignored the following grouping variables:
#> Column `Organisation`
#> # A tibble: 33 x 6
#> # Groups:   Organisation [1]
#>    Organisation          Grade `Professional/Occupation…   min   max    fte
#>    <chr>                 <chr> <chr>                     <dbl> <dbl>  <dbl>
#>  1 Joint Nature Conserv… All   All                       16284 63271 179.  
#>  2 Joint Nature Conserv… AA    All                       16284 17560   1   
#>  3 Joint Nature Conserv… AO    All                       18515 21226   9.3 
#>  4 Joint Nature Conserv… H     All                       27398 33159  62   
#>  5 Joint Nature Conserv… O     All                       22143 26945  19.6 
#>  6 Joint Nature Conserv… Other All                       44671 63271  25.8 
#>  7 Joint Nature Conserv… S     All                       35175 41889  61.1 
#>  8 Joint Nature Conserv… AA    Knowledge and Informatio… 16284 17560   1   
#>  9 Joint Nature Conserv… AO    Finance                   18515 21226   1   
#> 10 Joint Nature Conserv… AO    Human Resources           18515 21226   1   
#> 11 Joint Nature Conserv… AO    Information Technology    18515 21226   1   
#> 12 Joint Nature Conserv… AO    Knowledge and Informatio… 18515 21226   5.3 
#> 13 Joint Nature Conserv… AO    Science and Engineering   18515 21226   1   
#> 14 Joint Nature Conserv… H     Communications            27398 33159   1.5 
#> 15 Joint Nature Conserv… H     Finance                   27398 33159   1.89
#> 16 Joint Nature Conserv… H     Human Resources           27398 33159   2   
#> 17 Joint Nature Conserv… H     Knowledge and Informatio… 27398 33159   8.64
#> 18 Joint Nature Conserv… H     Science and Engineering   27398 33159  48.0 
#> 19 Joint Nature Conserv… O     Communications            22143 26945   1   
#> 20 Joint Nature Conserv… O     Finance                   22143 26945   1   
#> 21 Joint Nature Conserv… O     Human Resources           22143 26945   1.6 
#> 22 Joint Nature Conserv… O     Knowledge and Informatio… 22143 26945   5   
#> 23 Joint Nature Conserv… O     Science and Engineering   22143 26945  11   
#> 24 Joint Nature Conserv… Other Finance                   44671 53196   1   
#> 25 Joint Nature Conserv… Other Human Resources           44671 53196   1   
#> 26 Joint Nature Conserv… Other Information Technology    44671 53196   2   
#> 27 Joint Nature Conserv… Other Knowledge and Informatio… 44671 53196   2   
#> 28 Joint Nature Conserv… Other Science and Engineering   44671 63271  19.8 
#> 29 Joint Nature Conserv… S     Communications            35175 41889   2   
#> 30 Joint Nature Conserv… S     Finance                   35175 41889   2   
#> 31 Joint Nature Conserv… S     Human Resources           35175 41889   0.69
#> 32 Joint Nature Conserv… S     Information Technology    35175 41889   1   
#> 33 Joint Nature Conserv… S     Science and Engineering   35175 41889  55.4
```

Or it could be a different hierarchy, with Grade grouped inside
Profession.

``` r
organogram  %>%
  group_by(Organisation, `Professional/Occupational Group`, Grade) %>%
  margins(min = min(`Payscale Minimum (£)`),
          max = max(`Payscale Maximum (£)`),
          fte = sum(`Number of Posts in FTE`)) %>%
  mutate_if(is.character, replace_na, "All") %>%
  print(n = Inf)
#> `mutate_if()` ignored the following grouping variables:
#> Column `Organisation`
#> # A tibble: 33 x 6
#> # Groups:   Organisation [1]
#>    Organisation          `Professional/Occupation… Grade   min   max    fte
#>    <chr>                 <chr>                     <chr> <dbl> <dbl>  <dbl>
#>  1 Joint Nature Conserv… All                       All   16284 63271 179.  
#>  2 Joint Nature Conserv… Communications            All   22143 41889   4.5 
#>  3 Joint Nature Conserv… Finance                   All   18515 53196   6.89
#>  4 Joint Nature Conserv… Human Resources           All   18515 53196   6.29
#>  5 Joint Nature Conserv… Information Technology    All   18515 53196   4   
#>  6 Joint Nature Conserv… Knowledge and Informatio… All   16284 53196  21.9 
#>  7 Joint Nature Conserv… Science and Engineering   All   18515 63271 135.  
#>  8 Joint Nature Conserv… Communications            H     27398 33159   1.5 
#>  9 Joint Nature Conserv… Communications            O     22143 26945   1   
#> 10 Joint Nature Conserv… Communications            S     35175 41889   2   
#> 11 Joint Nature Conserv… Finance                   AO    18515 21226   1   
#> 12 Joint Nature Conserv… Finance                   H     27398 33159   1.89
#> 13 Joint Nature Conserv… Finance                   O     22143 26945   1   
#> 14 Joint Nature Conserv… Finance                   Other 44671 53196   1   
#> 15 Joint Nature Conserv… Finance                   S     35175 41889   2   
#> 16 Joint Nature Conserv… Human Resources           AO    18515 21226   1   
#> 17 Joint Nature Conserv… Human Resources           H     27398 33159   2   
#> 18 Joint Nature Conserv… Human Resources           O     22143 26945   1.6 
#> 19 Joint Nature Conserv… Human Resources           Other 44671 53196   1   
#> 20 Joint Nature Conserv… Human Resources           S     35175 41889   0.69
#> 21 Joint Nature Conserv… Information Technology    AO    18515 21226   1   
#> 22 Joint Nature Conserv… Information Technology    Other 44671 53196   2   
#> 23 Joint Nature Conserv… Information Technology    S     35175 41889   1   
#> 24 Joint Nature Conserv… Knowledge and Informatio… AA    16284 17560   1   
#> 25 Joint Nature Conserv… Knowledge and Informatio… AO    18515 21226   5.3 
#> 26 Joint Nature Conserv… Knowledge and Informatio… H     27398 33159   8.64
#> 27 Joint Nature Conserv… Knowledge and Informatio… O     22143 26945   5   
#> 28 Joint Nature Conserv… Knowledge and Informatio… Other 44671 53196   2   
#> 29 Joint Nature Conserv… Science and Engineering   AO    18515 21226   1   
#> 30 Joint Nature Conserv… Science and Engineering   H     27398 33159  48.0 
#> 31 Joint Nature Conserv… Science and Engineering   O     22143 26945  11   
#> 32 Joint Nature Conserv… Science and Engineering   Other 44671 63271  19.8 
#> 33 Joint Nature Conserv… Science and Engineering   S     35175 41889  55.4
```

Or there could be no hierarchy, with all combinations of Organisation,
Grade and Profession equally valid subsets.

``` r
organogram %>%
  group_by(Organisation, Grade, `Professional/Occupational Group`) %>%
  margins(min = min(`Payscale Minimum (£)`),
          max = max(`Payscale Maximum (£)`),
          fte = sum(`Number of Posts in FTE`),
          method = "combination") %>%
  mutate_if(is.character, replace_na, "All") %>%
  print(n = Inf)
#> `mutate_if()` ignored the following grouping variables:
#> Column `Organisation`
#> # A tibble: 77 x 6
#> # Groups:   Organisation [2]
#>    Organisation          Grade `Professional/Occupation…   min   max    fte
#>    <chr>                 <chr> <chr>                     <dbl> <dbl>  <dbl>
#>  1 Joint Nature Conserv… All   All                       16284 63271 179.  
#>  2 <NA>                  AA    All                       16284 17560   1   
#>  3 <NA>                  AO    All                       18515 21226   9.3 
#>  4 <NA>                  H     All                       27398 33159  62   
#>  5 <NA>                  O     All                       22143 26945  19.6 
#>  6 <NA>                  Other All                       44671 63271  25.8 
#>  7 <NA>                  S     All                       35175 41889  61.1 
#>  8 <NA>                  All   Communications            22143 41889   4.5 
#>  9 <NA>                  All   Finance                   18515 53196   6.89
#> 10 <NA>                  All   Human Resources           18515 53196   6.29
#> 11 <NA>                  All   Information Technology    18515 53196   4   
#> 12 <NA>                  All   Knowledge and Informatio… 16284 53196  21.9 
#> 13 <NA>                  All   Science and Engineering   18515 63271 135.  
#> 14 Joint Nature Conserv… AA    All                       16284 17560   1   
#> 15 Joint Nature Conserv… AO    All                       18515 21226   9.3 
#> 16 Joint Nature Conserv… H     All                       27398 33159  62   
#> 17 Joint Nature Conserv… O     All                       22143 26945  19.6 
#> 18 Joint Nature Conserv… Other All                       44671 63271  25.8 
#> 19 Joint Nature Conserv… S     All                       35175 41889  61.1 
#> 20 Joint Nature Conserv… All   Communications            22143 41889   4.5 
#> 21 Joint Nature Conserv… All   Finance                   18515 53196   6.89
#> 22 Joint Nature Conserv… All   Human Resources           18515 53196   6.29
#> 23 Joint Nature Conserv… All   Information Technology    18515 53196   4   
#> 24 Joint Nature Conserv… All   Knowledge and Informatio… 16284 53196  21.9 
#> 25 Joint Nature Conserv… All   Science and Engineering   18515 63271 135.  
#> 26 <NA>                  AA    Knowledge and Informatio… 16284 17560   1   
#> 27 <NA>                  AO    Finance                   18515 21226   1   
#> 28 <NA>                  AO    Human Resources           18515 21226   1   
#> 29 <NA>                  AO    Information Technology    18515 21226   1   
#> 30 <NA>                  AO    Knowledge and Informatio… 18515 21226   5.3 
#> 31 <NA>                  AO    Science and Engineering   18515 21226   1   
#> 32 <NA>                  H     Communications            27398 33159   1.5 
#> 33 <NA>                  H     Finance                   27398 33159   1.89
#> 34 <NA>                  H     Human Resources           27398 33159   2   
#> 35 <NA>                  H     Knowledge and Informatio… 27398 33159   8.64
#> 36 <NA>                  H     Science and Engineering   27398 33159  48.0 
#> 37 <NA>                  O     Communications            22143 26945   1   
#> 38 <NA>                  O     Finance                   22143 26945   1   
#> 39 <NA>                  O     Human Resources           22143 26945   1.6 
#> 40 <NA>                  O     Knowledge and Informatio… 22143 26945   5   
#> 41 <NA>                  O     Science and Engineering   22143 26945  11   
#> 42 <NA>                  Other Finance                   44671 53196   1   
#> 43 <NA>                  Other Human Resources           44671 53196   1   
#> 44 <NA>                  Other Information Technology    44671 53196   2   
#> 45 <NA>                  Other Knowledge and Informatio… 44671 53196   2   
#> 46 <NA>                  Other Science and Engineering   44671 63271  19.8 
#> 47 <NA>                  S     Communications            35175 41889   2   
#> 48 <NA>                  S     Finance                   35175 41889   2   
#> 49 <NA>                  S     Human Resources           35175 41889   0.69
#> 50 <NA>                  S     Information Technology    35175 41889   1   
#> 51 <NA>                  S     Science and Engineering   35175 41889  55.4 
#> 52 Joint Nature Conserv… AA    Knowledge and Informatio… 16284 17560   1   
#> 53 Joint Nature Conserv… AO    Finance                   18515 21226   1   
#> 54 Joint Nature Conserv… AO    Human Resources           18515 21226   1   
#> 55 Joint Nature Conserv… AO    Information Technology    18515 21226   1   
#> 56 Joint Nature Conserv… AO    Knowledge and Informatio… 18515 21226   5.3 
#> 57 Joint Nature Conserv… AO    Science and Engineering   18515 21226   1   
#> 58 Joint Nature Conserv… H     Communications            27398 33159   1.5 
#> 59 Joint Nature Conserv… H     Finance                   27398 33159   1.89
#> 60 Joint Nature Conserv… H     Human Resources           27398 33159   2   
#> 61 Joint Nature Conserv… H     Knowledge and Informatio… 27398 33159   8.64
#> 62 Joint Nature Conserv… H     Science and Engineering   27398 33159  48.0 
#> 63 Joint Nature Conserv… O     Communications            22143 26945   1   
#> 64 Joint Nature Conserv… O     Finance                   22143 26945   1   
#> 65 Joint Nature Conserv… O     Human Resources           22143 26945   1.6 
#> 66 Joint Nature Conserv… O     Knowledge and Informatio… 22143 26945   5   
#> 67 Joint Nature Conserv… O     Science and Engineering   22143 26945  11   
#> 68 Joint Nature Conserv… Other Finance                   44671 53196   1   
#> 69 Joint Nature Conserv… Other Human Resources           44671 53196   1   
#> 70 Joint Nature Conserv… Other Information Technology    44671 53196   2   
#> 71 Joint Nature Conserv… Other Knowledge and Informatio… 44671 53196   2   
#> 72 Joint Nature Conserv… Other Science and Engineering   44671 63271  19.8 
#> 73 Joint Nature Conserv… S     Communications            35175 41889   2   
#> 74 Joint Nature Conserv… S     Finance                   35175 41889   2   
#> 75 Joint Nature Conserv… S     Human Resources           35175 41889   0.69
#> 76 Joint Nature Conserv… S     Information Technology    35175 41889   1   
#> 77 Joint Nature Conserv… S     Science and Engineering   35175 41889  55.4
```

Or each one of Organisation, Grade and Profession could be summarised
individually.

``` r
organogram %>%
  group_by(Organisation, Grade, `Professional/Occupational Group`) %>%
  margins(min = min(`Payscale Minimum (£)`),
          max = max(`Payscale Maximum (£)`),
          fte = sum(`Number of Posts in FTE`),
          method = "individual") %>%
  mutate_if(is.character, replace_na, "All") %>%
  print(n = Inf)
#> `mutate_if()` ignored the following grouping variables:
#> Column `Organisation`
#> # A tibble: 13 x 6
#> # Groups:   Organisation [2]
#>    Organisation          Grade `Professional/Occupation…   min   max    fte
#>    <chr>                 <chr> <chr>                     <dbl> <dbl>  <dbl>
#>  1 Joint Nature Conserv… All   All                       16284 63271 179.  
#>  2 <NA>                  AA    All                       16284 17560   1   
#>  3 <NA>                  AO    All                       18515 21226   9.3 
#>  4 <NA>                  H     All                       27398 33159  62   
#>  5 <NA>                  O     All                       22143 26945  19.6 
#>  6 <NA>                  Other All                       44671 63271  25.8 
#>  7 <NA>                  S     All                       35175 41889  61.1 
#>  8 <NA>                  All   Communications            22143 41889   4.5 
#>  9 <NA>                  All   Finance                   18515 53196   6.89
#> 10 <NA>                  All   Human Resources           18515 53196   6.29
#> 11 <NA>                  All   Information Technology    18515 53196   4   
#> 12 <NA>                  All   Knowledge and Informatio… 16284 53196  21.9 
#> 13 <NA>                  All   Science and Engineering   18515 63271 135.
```

## Contributing

Please note that the ‘armgin’ project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.

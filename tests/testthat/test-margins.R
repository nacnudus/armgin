context("test-margins")

test_that("bind = TRUE outputs a single data frame", {
  x <-
    mtcars %>%
    dplyr::group_by(cyl, gear, am) %>%
    margins(bind = TRUE)
  expect_true(is.data.frame(x))
})

test_that("bind = FALSE outputs a list of data frames", {
  x <-
    mtcars %>%
    dplyr::group_by(cyl, gear, am) %>%
    margins(bind = FALSE)
  expect_equal(length(x), 3)
})

test_that("method = \"hierarchy\" applies groups in order", {
  x <-
    mtcars %>%
    dplyr::group_by(cyl, gear, am) %>%
    margins(bind = FALSE) %>%
    lapply(dplyr::groups) %>%
    as.character()
  expect_equal(x, c("list(cyl)", "list(cyl, gear)", "list(cyl, gear, am)"))
})

test_that("hierarchy = FALSE generates a message and applies `method = \"combination\"`", {
  x <-
    mtcars %>%
    dplyr::group_by(cyl, gear, am)
  expect_message(margins(x, hierarchy = FALSE))
  y <-
    x %>%
    margins(
      bind = FALSE,
      hierarchy = FALSE
    ) %>%
    lapply(dplyr::groups) %>%
    as.character()
  expect_equal(y, c(
    "list(cyl)", "list(gear)", "list(am)", "list(cyl, gear)",
    "list(cyl, am)", "list(gear, am)", "list(cyl, gear, am)"
  ))
})

test_that("method = \"combination\" applies all unordered combinations of groups", {
  x <-
    mtcars %>%
    dplyr::group_by(cyl, gear, am) %>%
    margins(
      bind = FALSE,
      method = "combination"
    ) %>%
    lapply(dplyr::groups) %>%
    as.character()
  expect_equal(x, c(
    "list(cyl)", "list(gear)", "list(am)", "list(cyl, gear)",
    "list(cyl, am)", "list(gear, am)", "list(cyl, gear, am)"
  ))
})

test_that("method = \"individual\" applies single groups alone", {
  x <-
    mtcars %>%
    dplyr::group_by(cyl, gear, am) %>%
    margins(
      bind = FALSE,
      method = "individual"
    ) %>%
    lapply(dplyr::groups) %>%
    as.character()
  expect_equal(x, c( "list(cyl)", "list(gear)", "list(am)"))
})

test_that("summary functions are applied", {
  x <-
    mtcars %>%
    dplyr::group_by(cyl, gear, am) %>%
    margins(
      hp = min(hp),
      mpg = mean(mpg)
    )
  expect_equal(x$hp[1], 52)
})

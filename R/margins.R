#' Summarise all margins of a grouped data frame in one go
#'
#' @description
#' Take a data frame grouped with [dplyr::group_by()) and summarise by
#' combinations of the grouping variables, e.g. by the first variable, by the
#' first two, the first three, etc.  With `method = "combination"` all
#' combinations will be summarised, e.g. `a`, `a` and `b`, `a` and `c`, `b` and
#' `c`.  With `method = "individual"` each grouping variable will be used once,
#' e.g. by the first variable, by the second variable, the third variable, etc.
#'
#' The output is a data frame with `NA` in unused grouping variables.
#' Alternatively use `bind = FALSE` to return a list of data frames, one per
#' combination of grouping variables.
#'
#' @inheritParams dplyr::summarise
#' @param bind Whether to combine all margins into one data frame. Default is
#'   `TRUE`.  If `FALSE`, returns a list of dataframes, one per margin.
#' @param method One of `"hierarchy"`, `"combination"`, and `"individual"`.
#'
#' * `"hierarchy" will treat the grouping variables as a hierarchy with the
#'   first variable at the top and the next variable inside it, e.g. with three
#'   variables `a`, `b` and `c` the combinations will be `a` alone, `a` and `b`
#'   together, and `a`, `b` and `c` together.
#' * `"combination" summarises by all combinations of grouping variables, e.g.
#'   with three variables `a`, `b` and `c` the combinations will be `a` alone,
#'   `a` and `b` together, `a` and `c` together, `b` and `c` together, and `a`,
#'   `b` and `c` together.
#' * `"individual" summarises by one grouping variable at a time, e.g.
#'   with three variables `a`, `b` and `c` the combinations will be `a` alone,
#'   `b` alone, and `c` alone.
#'
#' @param hierarchy Deprecated.  The default `TRUE` is the same as `method =
#' "hierarchy"`.  `FALSE` will do the same as `method = "combination"` and
#' generate a message.
#'
#' @export
#' @examples
#' mtcars %>%
#'   dplyr::group_by(cyl, gear, am) %>%
#'   margins(mpg = mean(mpg, na.rm = TRUE),
#'           hp = min(hp),
#'           bind = FALSE,
#'           method = "hierarchy")
#'
#' mtcars %>%
#'   dplyr::group_by(cyl, gear, am) %>%
#'   margins(mpg = mean(mpg, na.rm = TRUE),
#'           hp = min(hp),
#'           bind = TRUE,
#'           method = "hierarchy") %>%
#'   print(n = Inf)
#'
#' mtcars %>%
#'   dplyr::group_by(cyl, gear, am) %>%
#'   margins(mpg = mean(mpg, na.rm = TRUE),
#'           hp = min(hp),
#'           bind = FALSE,
#'           method = "combination")
#'
#' mtcars %>%
#'   dplyr::group_by(cyl, gear, am) %>%
#'   margins(mpg = mean(mpg, na.rm = TRUE),
#'           hp = min(hp),
#'           bind = FALSE,
#'           method = "individual")
margins <- function(.data, ..., bind = TRUE, method = c("hierarchy", "combination", "individual"), hierarchy = TRUE) {
  method <- match.arg(method)
  if (!hierarchy) {
    message("The 'hierarchy' argument of armgin::margins() is deprecated and will be removed in a future release.\nPlease use 'method = \"hierarchy\" instead.")
    method <- "combination"
  }
  groups <- dplyr::groups(.data)
  if (method == "individual") {
    combinations <- lapply(groups, list)
  } else if (method == "hierarchy") {
    # Create increasing combinations of groups, starting with the first
    combinations <- lapply(seq_along(groups), function(x) {
      groups[seq_len(x)]
    })
  } else if (method == "combination"){
    # Create all combinations of groups, excluding no groups
    # https://stackoverflow.com/a/27953641/937932
    combinations <-
      do.call(c, lapply(seq_along(groups), combn, x = groups, simplify = FALSE))
  }
  n <- length(combinations)
  out <- vector(mode = "list", length = n)
  for (i in rev(seq_len(n))) { # summarise by one column, then two, then etc.
    out[[i]] <-
      .data %>%
      dplyr::group_by(!!!combinations[[i]]) %>%
      dplyr::summarise(...) %>%
      dplyr::group_by(!!!combinations[[i]]) # Reapply the original groups
  }
  if (bind) {
    out <-
      out %>%
      dplyr::bind_rows() %>%
      dplyr::select(!!!groups, dplyr::everything())
  }
  out
}

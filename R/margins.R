#' Summarise all margins of a grouped data frame in one go
#'
#' @description
#' Take a data frame grouped with [dplyr::group_by()) and summarise by
#' combinations of the grouping variables, e.g. by the first variable, by the
#' first two, the first three, etc.  With `hierarchy = FALSE` all combinations
#' will be summarised, e.g. `a`, `a` and `b`, `a` and `c`, `b` and `c`.
#'
#' The output is a data frame with `NA` in unused grouping variables.
#' Alternatively use `bind = FALSE` to return a list of data frames, one per
#' combination of grouping variables.
#'
#' @inheritParams dplyr::group_by
#' @param bind Whether to combine all margins into one data frame. Default is
#'   `TRUE`.  If `FALSE`, returns a list of dataframes, one per margin.
#' @param hierarchy Whether to treat the grouping variables as a hierarchy with
#'   the first variable at the top and the next variable inside it.  Default is
#'   `TRUE`.  If `FALSE`, uses all unordered combinations of the grouping
#'   variables as margins.
#'
#' @export
#' @examples
#' mtcars %>%
#'   dplyr::group_by(cyl, gear, am) %>%
#'   margins(mpg = mean(mpg, na.rm = TRUE),
#'           hp = min(hp),
#'           bind = FALSE,
#'           hierarchy = TRUE)
#' mtcars %>%
#'   dplyr::group_by(cyl, gear, am) %>%
#'   margins(mpg = mean(mpg, na.rm = TRUE),
#'           hp = min(hp),
#'           bind = TRUE,
#'           hierarchy = TRUE) %>%
#'   print(n = Inf)
#' mtcars %>%
#'   dplyr::group_by(cyl, gear, am) %>%
#'   margins(mpg = mean(mpg, na.rm = TRUE),
#'           hp = min(hp),
#'           bind = FALSE,
#'           hierarchy = FALSE)
margins <- function(.data, ..., bind = TRUE, hierarchy = TRUE) {
  groups <- dplyr::groups(.data)
  if (hierarchy) {
    # Create increasing combinations of groups, starting with the first
    combinations <- lapply(seq_along(groups), function(x) {
      groups[seq_len(x)]
    })
  } else {
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

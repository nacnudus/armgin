#' Un-pivot complex and irregular data layouts.
#'
#' @description
#'
#' The armgin package summarises all combinations of grouping variables at
#' once. For example, vote counts by
#'
#' * voting place, ward, constituency, party, candidate
#' * voting place, ward, constituency, party
#' * voting place, ward, constituency
#' * voting place, ward,
#' * voting place
#'
#' Or with `hierarchy = FALSE` and grouping by only voting place, ward and
#' constituency (for brevity)
#'
#' * voting place, ward, constituency
#'
#' * voting place, ward
#' * voting place, constituency
#' * ward, constituency
#'
#' * voting place
#' * ward
#' * constituency
#'
#' Groups are defined as normal by [dplyr::group_by()] and then piped into
#' [margins()]
#'
#' @keywords internal
"_PACKAGE"

# These parameters have been renamed in the generated functions. They may have
# had confusing names in the API definition, or there might have been another
# motivation to rename the parameters. This mapping allows us to convert back
# and forth between the naming conventions.
param_renames <- c(
  limit = "per_page",
  other = "other_name"
)

#' Restore Slack API parameter names
#'
#' Translate package parameter names to Slack API parameter names.
#'
#' @param x (`list` or `character`) A named object that might have parameters to
#'   rename.
#' @returns `x` with parameters renamed.
#' @keywords internal
.apply_slack_param_names <- function(x) {
  if (rlang::is_named(x)) {
    names(x) <- replace(
      names(x),
      names(x) %in% param_renames,
      names(param_renames)[match(names(x), param_renames, nomatch = 0)]
    )
  }
  return(x)
}

#' Get users list
#'
#' Lists all users in a Slack team.
#'
#' @inheritParams slack_call_api
#' @param include_locale (`logical`) Set this to `TRUE` to receive the locale
#'   for users. Defaults to `FALSE`.
#' @param team_id (`character`) Encoded team id to list users in, required if
#'   org token is used.
#' @param include_locale (`logical`) Set this to `TRUE` to receive the locale
#'   for users. Defaults to `FALSE`.
#'
#' @return This method returns a list of all users in the workspace. This
#'   includes both invited users and deleted/deactivated users.
#' @export
slack_users_list <- function(include_locale = FALSE,
                             team_id = NULL,
                             max_results = Inf,
                             max_reqs = Inf,
                             token = Sys.getenv("SLACK_API_TOKEN")) {
  slack_call_api(
    path = "/users.list",
    method = "get",
    token = token,
    query = list(
      include_locale = include_locale,
      team_id = team_id
    ),
    pagination = "cursor",
    max_results = max_results,
    max_reqs = max_reqs
  )
}

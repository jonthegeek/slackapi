#' Get users info
#'
#' Gets information about a user.
#'
#' @inheritParams slack_call_api
#' @param user (`character`) User to get info on.
#' @param include_locale (`logical`) Set this to `TRUE` to receive the locale
#'   for users. Defaults to `FALSE`.
#'
#' @return This method returns information about a member of a workspace.
#' @export
slack_users_info <- function(user,
                             include_locale = FALSE,
                             max_results = Inf,
                             max_reqs = Inf,
                             token = Sys.getenv("SLACK_API_TOKEN")) {
  slack_call_api(
    path = "/users.info",
    method = "get",
    token = token,
    query = list(
      user = user,
      include_locale = include_locale
    ),
    max_results = max_results,
    max_reqs = max_reqs
  )
}

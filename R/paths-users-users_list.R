#' Get users list
#'
#' Lists all users in a Slack team.
#'
#' @inheritParams .shared-params
#' @param include_locale (`logical`) Set this to `TRUE` to receive the locale
#'   for users. Defaults to `FALSE`.
#' @param team_id (`character`) Encoded team id to list users in, required if
#'   org token is used.
#'
#' @returns `users_list()`: A list of all users in the workspace. This includes
#'   both invited users and deleted/deactivated users.
#' @export
users_list <- function(include_locale = FALSE,
                       team_id = NULL,
                       per_req = 200L,
                       max_reqs = Inf,
                       max_tries_per_req = 3,
                       token = Sys.getenv("SLACK_API_TOKEN")) {
  req <- req_users_list(
    include_locale = include_locale,
    team_id = team_id,
    per_req = per_req,
    token = token
  )
  resps <- nectar::req_perform_opinionated(
    req,
    max_reqs = max_reqs,
    max_tries_per_req = max_tries_per_req
  )
  return(nectar::resp_tidy(resps))
}

#' @rdname users_list
#' @returns `req_users_list()`: A `httr2_request` request object that lists all
#'   users in a Slack team.
req_users_list <- function(include_locale = FALSE,
                           team_id = NULL,
                           per_req = 200L,
                           token = Sys.getenv("SLACK_API_TOKEN")) {
  include_locale <- stbl::to_lgl_scalar(
    include_locale,
    allow_null = FALSE
  )
  per_req <- stbl::stabilize_int_scalar(
    per_req,
    allow_null = FALSE,
    allow_zero_length = FALSE,
    allow_na = FALSE,
    min_value = 1L,
    max_value = 999L
  )
  team_id <- stbl::to_chr_scalar(team_id)
  slack_req_prepare(
    path = "/users.list",
    method = "get",
    token = token,
    query = list(
      include_locale = include_locale,
      team_id = team_id,
      per_req = per_req
    ),
    pagination = "cursor",
    tidy_fn = tidy_members
  )
}

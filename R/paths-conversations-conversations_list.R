#' Get conversations list
#'
#' Lists all channels in a Slack team.
#'
#' @inheritParams .shared-params
#' @param exclude_archived (`logical`) Set to `TRUE` to exclude archived
#'   channels from the list.
#' @param types (`character`) Mix and match channel types by providing a vector
#'   of any combination of `public_channel`, `private_channel`, `mpim`, `im`.
#'
#' @returns `conversations_list()`: A tibble of information about channels and
#'   channel-like conversations.
#' @export
conversations_list <- function(exclude_archived = FALSE,
                               per_req = 200L,
                               team_id = NULL,
                               types = c(
                                 "public_channel",
                                 "private_channel",
                                 "mpim",
                                 "im"
                               ),
                               max_reqs = Inf,
                               max_tries_per_req = 3,
                               token = Sys.getenv("SLACK_API_TOKEN")) {
  req <- req_conversations_list(
    exclude_archived = exclude_archived,
    per_req = per_req,
    team_id = team_id,
    types = types,
    token = token
  )
  resps <- nectar::req_perform_opinionated(
    req,
    max_reqs = max_reqs,
    max_tries_per_req = max_tries_per_req
  )
  return(nectar::resp_tidy(resps))
}

#' @rdname conversations_list
#' @returns `req_conversations_list()`: A `httr2_request` request object to list
#'   all channels in a Slack team.
req_conversations_list <- function(exclude_archived = FALSE,
                                   per_req = 200L,
                                   team_id = NULL,
                                   types = c(
                                     "public_channel",
                                     "private_channel",
                                     "mpim",
                                     "im"
                                   ),
                                   token = Sys.getenv("SLACK_API_TOKEN")) {
  exclude_archived <- stbl::to_lgl_scalar(exclude_archived, FALSE, FALSE)
  per_req <- stbl::stabilize_int_scalar(
    per_req,
    allow_null = FALSE,
    allow_zero_length = FALSE,
    allow_na = FALSE,
    min_value = 1L,
    max_value = 1000L
  )
  team_id <- stbl::to_chr_scalar(team_id)
  types <- rlang::arg_match(types, multiple = TRUE)
  slack_req_prepare(
    path = "/conversations.list",
    method = "get",
    token = token,
    query = list(
      exclude_archived = exclude_archived,
      per_req = per_req,
      team_id = team_id,
      types = types,
      .multi = "comma"
    ),
    pagination = "cursor",
    tidy_fn = tidy_channels
  )
}

#' Get conversations history
#'
#' Retrieve members of a conversation.
#'
#' @return BKTODO: Return descriptions are not yet implemented in beekeeper
#' @keywords internal
#'
#' @inheritParams .shared-params
#' @param channel (`character`) ID of the conversation to retrieve members for.
#'
#' @returns `conversations_members()`: A list of user IDs belonging to the
#'   members in a conversation.
#' @export
conversations_members <- function(channel,
                                  per_req = 200L,
                                  max_reqs = Inf,
                                  max_tries_per_req = 3,
                                  token = Sys.getenv("SLACK_API_TOKEN")) {
  req <- req_conversations_members(
    channel = channel,
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

#' @rdname conversations_members
#' @returns `req_conversations_members()`: A `httr2_request` request object to
#'   retrieve members of a conversation.
req_conversations_members <- function(channel,
                                      per_req = 200L,
                                      token = Sys.getenv("SLACK_API_TOKEN")) {
  channel <- stbl::to_chr_scalar(
    channel,
    allow_null = FALSE,
    allow_zero_length = FALSE
  )
  per_req <- stbl::stabilize_int_scalar(
    per_req,
    allow_null = FALSE,
    allow_zero_length = FALSE,
    allow_na = FALSE,
    min_value = 1L,
    max_value = 999L
  )
  slack_req_prepare(
    path = "/conversations.members",
    method = "get",
    token = token,
    query = list(
      channel = channel,
      per_req = per_req
    ),
    pagination_fn = slack_pagination_cursor,
    tidy_fn = tidy_members_ids
  )
}

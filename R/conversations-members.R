#' Get conversations members
#'
#' Retrieve members of a conversation.
#'
#' @inheritParams slack_call_api
#' @param team_id (`character`) Encoded team id to list channels in, required if
#'   token belongs to org-wide app.
#' @param exclude_archived (`logical`) Set to `TRUE` to exclude archived
#'   channels from the list.
#' @param types (`character`) Mix and match channel types by
#'   providing a vector of any combination of `public_channel`,
#'   `private_channel`, `mpim`, `im`.
#'
#' @return A thread of messages posted to a conversation as a tibble. Note: The
#'   parent message is always included in the response.
#' @export
slack_conversations_members <- function(channel,
                                        max_results = Inf,
                                        max_reqs = Inf,
                                        token = Sys.getenv("SLACK_API_TOKEN")) {
  slack_call_api(
    path = "/conversations.members",
    method = "get",
    token = token,
    query = list(channel = channel),
    pagination = "cursor",
    max_results = max_results,
    max_reqs = max_reqs
  )
}

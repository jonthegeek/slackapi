#' Get conversations members
#'
#' Retrieve members of a conversation.
#'
#' @inheritParams slack_call_api
#'
#' @return A thread of messages posted to a conversation as a tibble. Note: The
#'   parent message is always included in the response.
#' @keywords internal
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

#' Get conversation replies
#'
#' Retrieve a thread of messages posted to a conversation.
#'
#' @inheritParams slack_call_api
#' @param channel (`character`) Conversation ID to fetch thread from.
#' @param ts (`character` or `datetime` or `double`) Unique identifier of either
#'   a thread’s parent message or a message in the thread. ts must be the
#'   timestamp of an existing message with 0 or more replies. If there are no
#'   replies then just the single message referenced by ts will return - it is
#'   just an ordinary, unthreaded message.
#' @param latest (`datetime` or `double`) Only messages before this Unix
#'   timestamp will be included in results.
#' @param oldest (`datetime` or `double`) Only messages after this Unix
#'   timestamp will be included in results.
#' @param inclusive (`logical`) Include messages with `latest` or `oldest`
#'   timestamp in results only when either timestamp is specified.
#' @param include_all_metadata (`logical`) Return all metadata associated with
#'   this message.
#'
#' @return A thread of messages posted to a conversation as a tibble. Note: The
#'   parent message is always included in the response.
#' @export
slack_conversations_replies <- function(channel,
                                        ts,
                                        latest = lubridate::now(),
                                        oldest = 0,
                                        inclusive = TRUE,
                                        include_all_metadata = FALSE,
                                        max_results = Inf,
                                        max_reqs = Inf,
                                        token = Sys.getenv("SLACK_API_TOKEN")) {
  latest <- as_slack_ts(latest)
  oldest <- as_slack_ts(oldest)
  slack_call_api(
    path = "/conversations.replies",
    method = "get",
    token = token,
    query = list(
      channel = channel,
      ts = ts,
      latest = latest,
      oldest = oldest,
      inclusive = inclusive,
      include_all_metadata = include_all_metadata
    ),
    pagination = "cursor",
    max_results = max_results,
    max_reqs = max_reqs
  )
}

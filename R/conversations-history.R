#' Get conversation history
#'
#' Fetches a conversation's history of messages and events.
#'
#' @inheritParams slack_call_api
#' @param channel (`character`) Conversation ID to fetch history for.
#' @param latest (`datetime` or `double`) End of time range of messages to
#'   include in results.
#' @param oldest (`datetime` or `double`) Start of time range of messages to
#'   include in results.
#' @param inclusive (`logical`) Include messages with `latest` or `oldest`
#'   timestamp in results only when either timestamp is specified.
#' @param include_all_metadata (`logical`) Return all metadata associated with
#'   this message.
#'
#' @return A channel's messages as a tibble.
#' @export
slack_conversations_history <- function(channel,
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
    path = "/conversations.history",
    method = "get",
    token = token,
    query = list(
      channel = channel,
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

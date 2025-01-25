#' Get conversations history
#'
#' Fetches a conversation's history of messages and events.
#'
#' @inheritParams .shared-params
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
#' @returns `conversations_history()`: A channel's messages as a tibble.
#' @export
conversations_history <- function(channel,
                                  latest = lubridate::now(),
                                  oldest = 0,
                                  inclusive = TRUE,
                                  include_all_metadata = FALSE,
                                  per_req = 200L,
                                  max_reqs = Inf,
                                  max_tries_per_req = 3,
                                  token = Sys.getenv("SLACK_API_TOKEN")) {
  req <- req_conversations_history(
    channel = channel,
    latest = latest,
    oldest = oldest,
    inclusive = inclusive,
    include_all_metadata = include_all_metadata,
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

#' @rdname conversations_history
#' @returns `req_conversations_history()`: A `httr2_request` request object to
#'   fetch a conversation's history of messages and events.
req_conversations_history <- function(channel,
                                      latest = lubridate::now(),
                                      oldest = 0,
                                      inclusive = TRUE,
                                      include_all_metadata = FALSE,
                                      per_req = 200L,
                                      token = Sys.getenv("SLACK_API_TOKEN")) {
  channel <- stbl::to_chr_scalar(
    channel,
    allow_null = FALSE,
    allow_zero_length = FALSE
  )
  latest <- as_slack_ts(latest)
  oldest <- as_slack_ts(oldest)
  inclusive <- stbl::to_lgl_scalar(
    inclusive,
    allow_null = FALSE
  )
  include_all_metadata <- stbl::to_lgl_scalar(
    include_all_metadata,
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
  slack_req_prepare(
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
    tidy_fn = tidy_messages
  )
}

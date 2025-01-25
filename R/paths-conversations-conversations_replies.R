#' Get conversations replies
#'
#' Retrieve a thread of messages posted to a conversation
#'
#' @inheritParams .shared-params
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
#' @returns `conversations_replies()`: A thread of messages posted to a
#'   conversation as a tibble. Note: The parent message is always included in
#'   the response.
#' @export
conversations_replies <- function(channel,
                                  ts,
                                  latest = lubridate::now(),
                                  oldest = 0,
                                  inclusive = TRUE,
                                  include_all_metadata = FALSE,
                                  per_req = 200L,
                                  max_reqs = Inf,
                                  max_tries_per_req = 3,
                                  token = Sys.getenv("SLACK_API_TOKEN")) {
  req <- req_conversations_replies(
    channel = channel,
    ts = ts,
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

#' @rdname conversations_replies
#' @returns `req_conversations_replies()`: A `httr2_request` request object to
#'   retrieve a thread of messages posted to a conversation as a tibble. Note:
#'   The parent message is always included in the response.
req_conversations_replies <- function(channel,
                                      ts,
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
  ts <- as_slack_ts(ts)
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
    tidy_fn = tidy_messages
  )
}

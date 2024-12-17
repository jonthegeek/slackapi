# Set up the basic call once at package build.
slack_req_base <- nectar::req_setup(
  "https://slack.com/api",
  user_agent = "slackapi (https://github.com/jonthegeek/slackapi)"
)

#' Call the Slack Web API
#'
#' Generate and perform request to a Slack Web API method.
#'
#' @inheritParams nectar::req_modify
#' @inheritParams .slack_req_perform
#' @inheritParams rlang::args_error_context
#' @param response_parser (`function`) A function to parse the server response.
#'   Defaults to [slack_response_parser()]. Set this to `NULL` to return the raw
#'   response from [httr2::req_perform()].
#' @param token (`character`) A bearer token provided by Slack. A later
#'   enhancement will add the ability to generate this token. Slack token are
#'   long-lasting, and should be carefully guarded.
#'
#' @return A tibble with the results of the API call.
#' @keywords internal
slack_call_api <- function(path,
                           query = list(),
                           body = NULL,
                           method = NULL,
                           pagination = c("none", "cursor"),
                           max_results = Inf,
                           max_reqs = Inf,
                           response_parser = slack_response_parser,
                           token = Sys.getenv("SLACK_API_TOKEN"),
                           call = rlang::caller_env()) {
  # Don't pass token in query or body if provided as parameters; we'll instead
  # pass it in the header.
  token <- token %||% body$token %||% query$token
  if (length(body)) {
    body$token <- NULL
  }
  if (length(query)) {
    query$token <- NULL
  }

  req <- nectar::req_modify(
    slack_req_base,
    path = path,
    query = query,
    body = body,
    method = method
  )
  req <- .slack_req_auth(req, token = token)

  resps <- .slack_req_perform(
    req,
    pagination = pagination,
    max_results = max_results,
    max_reqs = max_reqs,
    call = call
  )

  nectar::resp_parse(resps, response_parser = response_parser)
}

#' Choose and apply pagination strategy
#'
#' @inheritParams rlang::args_error_context
#' @inheritParams nectar::req_perform_opinionated
#' @param req (`httr2_request`) The request object to modify.
#' @param pagination (`character`) The pagination scheme to use. Currently either
#'   "none" (the default) or "cursor" (a scheme that uses `cursor`-based
#'   pagination; see [Pagination through
#'   collections](https://api.slack.com/apis/pagination) in the Slack API
#'   documentation. We do not currently support "Classic pagination".
#' @param max_results (`integer` or `Inf`) The maximum number of results to
#'   return. Note that slightly more results may be returned if `max_results` is
#'   not evenly divisible by 100.
#'
#' @inherit nectar::req_perform_opinionated return
#' @keywords internal
.slack_req_perform <- function(req,
                               pagination,
                               max_results,
                               max_reqs,
                               call) {
  next_req <- NULL
  if (max_reqs > 1) {
    next_req <- .choose_pagination_fn(pagination, call = call)
    if (!is.null(next_req)) {
      # Use Slack's recommended limit when paginating.
      per_page <- 200L
      max_reqs <- min(max_reqs, ceiling(max_results / per_page))
      req <- httr2::req_url_query(req, limit = per_page)
    }
  }

  # nectar respects it if we put our own retry mechanism on. Slack has retry
  # tiers, so it MIGHT make sense to implement those specifically. Dunno if
  # Slack sends back info around that, need to check; it seems to always wait 10
  # seconds.

  nectar::req_perform_opinionated(
    req,
    next_req = next_req,
    max_reqs = max_reqs
  )
}

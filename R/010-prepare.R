#' Generate a request for the Slack API
#'
#' Prepare a request for the Slack API, using the opinionated framework defined
#' in [nectar::req_init()], [nectar::req_modify()], [nectar::req_tidy_policy()],
#' and [nectar::req_pagination_policy()].
#'
#' I may export this eventually, but hopefully I won't have to.
#'
#' @inheritParams .shared-params
#' @inheritParams nectar::req_prepare
#' @inherit nectar::req_prepare return
#' @keywords internal
slack_req_prepare <- function(path,
                              query = list(),
                              body = NULL,
                              method = NULL,
                              pagination = c("none", "cursor"),
                              tidy_fn = tidy_slack,
                              token = Sys.getenv("SLACK_API_TOKEN"),
                              call = rlang::caller_env()) {
  token <- .find_token(token, body, query)
  body <- .prepare_list(body)
  query <- .prepare_list(query)
  req <- nectar::req_prepare(
    "https://slack.com/api",
    path = path,
    query = query,
    body = body,
    method = method,
    auth_fn = .req_auth,
    auth_args = list(token = token),
    tidy_fn = tidy_fn,
    pagination_fn = .choose_pagination_fn(pagination, call = call)
  )
  return(req)
}

.prepare_list <- function(x = NULL) {
  if (length(x)) {
    x$token <- NULL
    x <- .apply_slack_param_names(x)
  }
  return(x)
}

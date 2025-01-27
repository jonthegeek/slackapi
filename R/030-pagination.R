#' Apply cursor-based pagination
#'
#' Process a `resp` object to extract the next cursor, and build the next `req`.
#' Use as the `pagination_fn` argument to [slack_req_prepare()].
#'
#' @inheritParams .shared-params
#' @inherit nectar::req_prepare return
#' @keywords internal
slack_pagination_cursor <- function(resp, req) {
  nectar::iterate_with_json_cursor(
    "cursor",
    c("response_metadata", "next_cursor")
  )(resp, req)
}

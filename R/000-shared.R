#' Parameters used in multiple functions
#'
#' Reused parameter definitions are gathered here for easier editing.
#'
#' @param max_reqs (`integer`) The maximum number of separate requests to
#'   perform. Passed on to [nectar::req_perform_opinionated()].
#' @param max_tries_per_req (`integer`) The maximum number of times to attempt
#'   each individual request. Passed on to [nectar::req_perform_opinionated()].
#' @param pagination_fn (`function`) The pagination scheme to use. Currently
#'   either `NULL` (no pagination, the default) or `slack_pagination_cursor` to
#'   use [slack_pagination_cursor()] for `cursor`-based pagination. See
#'   [Pagination through collections](https://api.slack.com/apis/pagination) in
#'   the Slack API documentation. We do not currently support "Classic
#'   pagination".
#' @param per_req (`integer`) The maximum number of items to return. Fewer than
#'   the requested number of items may be returned, even if the end of the list
#'   hasn't been reached. Must be an integer under 1000.
#' @param req (`httr2_request`) The request object to modify.
#' @param resp (`httr2_response`) A [httr2::response()] object (as returned by
#'   [httr2::req_perform()]).
#' @param team_id (`character`) Encoded team id to list channels in, required if
#'   token belongs to org-wide app.
#' @param token (`character`) A bearer token provided by Slack. A later
#'   enhancement will add the ability to generate this token. Slack token are
#'   long-lasting, and should be carefully guarded.
#' @param ... These dots are for future extensions and must be empty.
#'
#' @name .shared-params
#' @keywords internal
NULL

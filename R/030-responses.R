#' Basic stop-gap parsing
#'
#' @inheritParams httr2::resp_body_json
#'
#' @return A tibble of results.
#' @export
slack_response_parser <- function(resp) {
  # This will only work for a few things right now. We need more complete
  # parsing.
  #
  # I intentionally left the targeting of specific parsers in here for other
  # endpoints that return those same types of objects.
  results <- httr2::resp_body_json(resp)
  if (length(results)) {
    if ("messages" %in% names(results)) {
      return(
        # TODO: If I (even ~naively) specify the spec, I think I can silence the
        # messages about unspecified.
        tibblify::tibblify(
          results[["messages"]], unspecified = "list"
        )
      )
    }
    if ("channels" %in% names(results)) {
      return(.parse_channel(results$channels))
    }
    if ("user" %in% names(results)) {
      obj <- results[["user"]]
      profile <- obj$profile
      obj$profile <- NULL
      profile$real_name <- NULL
      to_return <- tibble::as_tibble(obj) |>
        dplyr::mutate(
          profile = list(profile)
        ) |>
        tidyr::unnest_wider(profile)
      return(to_return)
    }
    if ("members" %in% names(results)) {
      return(.parse_members(results$members))
    }
  }
  cli::cli_abort(c(
    "Don't know how to parse this response.",
    i = "Response pieces: {names(results)}"
  ))
}

tidy_slack <- function(resp) {
  results <- httr2::resp_body_json(resp)
  cli::cli_abort(c(
    "Don't know how to parse this response.",
    i = "Response pieces: {names(results)}"
  ))
}

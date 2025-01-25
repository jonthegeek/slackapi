tidy_messages <- function(resp) {
  results <- nectar::resp_tidy_json(
    resp,
    spec = NULL,
    subset_path = "messages"
  )
  return(results)
}

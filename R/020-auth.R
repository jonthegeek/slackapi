.slack_req_auth <- function(req, token = NULL) {
  if (!is.null(token)) {
    req <- httr2::req_auth_bearer_token(req, token)
  }
  return(req)
}

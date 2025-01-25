.req_auth <- function(req, token = NULL) {
  if (!is.null(token)) {
    req <- httr2::req_auth_bearer_token(req, token)
  }
  return(req)
}

.find_token <- function(token = NULL, body = NULL, query = NULL) {
  token %||% body$token %||% query$token
}

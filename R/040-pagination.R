.validate_pagination <- function(pagination, call = rlang::caller_env()) {
  rlang::arg_match0(
    pagination,
    c("none", "cursor"),
    error_call = call
  )
}

.iterator_fn_cursor <- function() {
  httr2::iterate_with_cursor(
    "cursor",
    resp_param_value = function(resp) {
      cursor <- httr2::resp_body_json(resp)$response_metadata$next_cursor
      if (!length(cursor) || cursor == "") {
        cursor <- NULL
      }
      return(cursor)
    }
  )
}

.choose_pagination_fn <- function(pagination, call = rlang::caller_env()) {
  pagination <- .validate_pagination(pagination, call)
  switch(pagination,
         cursor = .iterator_fn_cursor(),
         none = NULL
  )
}

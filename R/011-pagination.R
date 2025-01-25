.validate_pagination <- function(pagination, call = rlang::caller_env()) {
  rlang::arg_match0(
    pagination,
    c("none", "cursor"),
    error_call = call
  )
}

.choose_pagination_fn <- function(pagination, call = rlang::caller_env()) {
  pagination <- .validate_pagination(pagination, call)
  switch(pagination,
         cursor = nectar::iterate_with_json_cursor(
           "cursor",
           c("response_metadata", "next_cursor")
         ),
         none = NULL
  )
}

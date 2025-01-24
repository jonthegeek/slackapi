as_slack_ts <- function(x,
                        arg = rlang::caller_arg(x),
                        call = rlang::caller_env()) {
  UseMethod("as_slack_ts")
}

#' @export
as_slack_ts.POSIXct <- function(x,
                                arg = rlang::caller_arg(x),
                                call = rlang::caller_env()) {
  as_slack_ts(as.numeric(x), arg = arg, call = call)
}

#' @export
as_slack_ts.numeric <- function(x,
                                arg = rlang::caller_arg(x),
                                call = rlang::caller_env()) {
  stbl::stabilize_chr_scalar(x, allow_na = FALSE, x_arg = arg, call = call)
}

#' @export
as_slack_ts.character <- function(x,
                                  arg = rlang::caller_arg(x),
                                  call = rlang::caller_env()) {
  # TODO: Ideally this should detect whether this is datetime-y or double-y. It
  # should also probably use a stbl::to_dbl() function that doesn't exist yet,
  # to give better errors about NA.
  #
  # TODO: We lose precision in this, and that breaks things when we're using it
  # as an id. We need to be able to go in both directions. It might need a
  # special class or attribute when we convert these to datetimes?
  #
  # as_slack_ts(as.double(x), arg = arg, call = call)
  stbl::stabilize_chr_scalar(x, allow_na = FALSE, x_arg = arg, call = call)
}

#' @export
as_slack_ts.default <- function(x,
                                arg = rlang::caller_arg(x),
                                call = rlang::caller_env()) {
  cli::cli_abort(
    c(
      "Cannot convert object to Slack timestamp",
      i = "{.arg {arg}} is {.obj_type_friendly {x}}."
    ),
    call = call
  )
}

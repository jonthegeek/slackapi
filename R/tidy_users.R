tidy_users <- function(resp) {
  results <- httr2::resp_body_json(resp)
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

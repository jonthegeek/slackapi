users <- slack_users_list(include_locale = TRUE)

saveRDS(resps, "data-raw/users/user-resps.rds")
resps <- readRDS("data-raw/users/user-resps.rds")

results <- resps |>
  purrr::map(
    \(resp) {
      results <- httr2::resp_body_json(resp)
      results$members
    }
  ) |>
  purrr::flatten()

tibblify::guess_tspec_df(results)

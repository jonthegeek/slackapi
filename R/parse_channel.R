.parse_channel <- function(resp) {
  results <- httr2::resp_body_json(resp)$channels
  tibblify::tibblify(
    results,
    spec = tspec_slack_channels(),
    unspecified = "list"
  ) |>
    dplyr::mutate(
      channel_type = dplyr::case_when(
        is_im ~ "im",
        is_mpim ~ "mpim",
        is_private ~ "private_channel",
        .default = "public_channel"
      ),
      .after = "channel_name",
      .keep = "unused"
    )
}

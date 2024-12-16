convos <- slack_conversations_history("C06DGLX8U4V") |>
  dplyr::arrange(ts) |>
  tidyr::unnest(pinned_info) |>
  dplyr::select(
    "user",
    "ts",
    "text",
    "reactions",
    "thread_ts",
    "reply_count",
    "reply_users_count",
    "latest_reply",
    "reply_users",
    "files",
    "pinned_by",
    "pinned_ts"
  )

user_info <- convos |>
  dplyr::distinct(.data$user) |>
  dplyr::mutate(
    user_info = purrr::map(.data$user, slack_users_info)
  ) |>
  tidyr::unnest_wider("user_info") |>
  dplyr::select("user", "real_name_normalized", "display_name_normalized") |>
  dplyr::mutate(
    dplyr::across(
      tidyselect::everything(),
      \(x) dplyr::na_if(x, "")
    )
  ) |>
  dplyr::summarize(
    user_name = dplyr::coalesce(
      .data$display_name_normalized,
      .data$real_name_normalized
    ),
    .by = "user"
  )

convos <- convos |>
  dplyr::left_join(user_info, by = "user") |>
  dplyr::select("user", "user_name", tidyselect::everything())

threads <- convos |>
  dplyr::filter(!is.na(reply_count)) |>
  dplyr::pull(ts) |>
  purrr::map(
    \(ts) {
      slack_conversations_replies(channel = "C06DGLX8U4V", ts = ts)
    },
    .progress = TRUE
  ) |>
  purrr::list_rbind() |>
  dplyr::filter(is.na(reply_count)) |>
  dplyr::left_join(user_info, by = "user") |>
  dplyr::select("user", "user_name", "thread_ts", "ts", "text", "reactions") |>
  dplyr::arrange("thread_ts", "ts") |>
  tidyr::nest(.by = "thread_ts", .key = "replies")

convos <- convos |>
  dplyr::left_join(threads, by = "thread_ts") |>
  dplyr::mutate(
    timestamp = lubridate::as_datetime(as.double(.data$ts)),
    .before = "ts"
  ) |>
  dplyr::mutate(
    dplyr::across(
      c("thread_ts", "latest_reply", "pinned_ts"),
      \(ts) {
        lubridate::as_datetime(as.double(ts))
      }
    )
  )
saveRDS(convos, "data-raw/mentor_training_convos.rds")

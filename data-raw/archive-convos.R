pkgload::load_all(".", helpers = FALSE, attach_testthat = FALSE)

channels <- slack_conversations_list(
  types = "public_channel",
  exclude_archived = TRUE
)

# I was going to only get conversations since the last time I ran this script,
# but I need to get all and then use ts and latest_reply to figure out what has
# changed.

convos_new <- purrr::map(channels$channel_id, \(channel_id) {
  slack_conversations_history(channel = channel_id) |>
    dplyr::mutate(channel_id = channel_id, .before = 1)
}) |>
  purrr::list_rbind() |>
  dplyr::arrange(.data$channel_id, .data$ts) |>
  dplyr::mutate(
    dplyr::across(
      tidyselect::ends_with("_count"),
      \(x) {
        tidyr::replace_na(x, 0)
      }
    )
  ) |>
  dplyr::select(
    -tidyselect::any_of(c(
      "client_msg_id",
      "team",
      "is_locked",
      "subscribed",
      "last_read",
      "display_as_bot",
      "x_files",
      "saved",
      "root",
      "hidden",
      "parent_user_id",
      "bot_id",
      "app_id",
      "bot_profile",
      "username",
      "icons",
      "item_type",
      "new_broadcast",
      "bot_link"
    ))
  )

# Load the old data to see what has changed.
convos_old <- readRDS("data-raw/convos/convos_all.rds")
convos_old_compare <- convos_old |>
  dplyr::select(
    "channel_id",
    "ts",
    "edited",
    "reply_count",
    "latest_reply",
    "reactions",
    "subtype"
  )

# We only need to save the *changes* to conversations (and this is all we'll
# need below).
convo_changes <- convos_new |>
  dplyr::anti_join(convos_old_compare, by = colnames(convos_old_compare))

if (nrow(convo_changes)) {
  convos_all <- convos_old |>
    dplyr::anti_join(convos_new, by = c("channel_id", "ts")) |>
    dplyr::bind_rows(convos_new) |>
    dplyr::arrange(.data$channel_id, .data$ts)

  saveRDS(convos_all, "data-raw/convos/convos_all.rds")

  ts_for_filename <- max(
    c(convo_changes$ts, convo_changes$latest_reply),
    na.rm = TRUE
  ) |>
    as.double() |>
    as.POSIXct(
      origin = "1970-01-01",
      tz = "UTC"
    ) |>
    format(format = "%Y-%m-%d-%H%M%OS0%Z")
  convos_filename <- paste0("data-raw/convos/convos-", ts_for_filename, ".rds")

  saveRDS(convo_changes, convos_filename)

  # Figure out what has changed/needs thread-loading. I'm making the decision NOT
  # to keep both the old and new versions of edited messages. However, note that
  # we also are NOT getting random replies that have been edited without anything
  # else in their thread changing. We would need to get every thread in case a
  # message was edited, and that isn't worthwhile, since we'll pick up the change
  # if it led to a reply.

  convos_old_thread_info <- convos_old |>
    dplyr::filter(
      # The subtypes that can have replies.
      is.na(.data$subtype) |
        .data$subtype %in% c("bot_message", "slackbot_response", "tombstone")
    ) |>
    dplyr::select(
      "channel_id",
      "ts",
      "reply_count", # So we can get rid of deleted replies.
      "latest_reply"
    )

  convos_with_reply_changes <- convo_changes |>
    dplyr::filter(reply_count > 0) |>
    dplyr::select(
      "channel_id",
      "ts",
      "reply_count",
      "latest_reply"
    ) |>
    dplyr::anti_join(
      convos_old_thread_info,
      by = c("channel_id", "ts", "reply_count", "latest_reply")
    )

  threads_new <- convos_with_reply_changes |>
    dplyr::select("channel_id", "ts") |>
    purrr::pmap(\(channel_id, ts) {
      slack_conversations_replies(channel = channel_id, ts = ts) |>
        dplyr::mutate(channel_id = channel_id, .before = 1)
    }) |>
    purrr::list_rbind() |>
    # Remove the parent messages.
    dplyr::filter(is.na(.data$reply_count)) |>
    # Get rid of columns that are nonsensical or redundant.
    dplyr::select(
      -tidyselect::any_of(
        c(
          "type",
          "subtype",
          "client_msg_id",
          "team",
          "reply_count",
          "reply_users_count",
          "latest_reply",
          "reply_users",
          "is_locked",
          "subscribed",
          "display_as_bot",
          "last_read",
          # Old fields.
          "root",
          "room",
          "username",
          "icons",
          "bot_id",
          "hidden",
          "x_files",
          "app_id",
          "bot_profile",
          "saved",
          "pinned_to",
          "pinned_info",
          "channel",
          "no_notifications",
          "permalink"
        )
      )
    )

  threads_old <- readRDS("data-raw/convos/threads_all.rds")

  threads_old_compare <- threads_old |>
    dplyr::select(
      "channel_id",
      "ts",
      "reactions",
      "edited"
    )

  common_columns <- intersect(
    colnames(threads_old_compare),
    colnames(threads_new)
  )

  thread_changes <- threads_new |>
    dplyr::anti_join(threads_old_compare, by = common_columns)

  if (nrow(thread_changes)) {
    ts_for_threads_filename <- thread_changes |>
      tidyr::unnest("edited", names_sep = "_") |>
      dplyr::select("ts", "edited_ts") |>
      dplyr::summarize(
        change_ts = max(c(
          as.double(.data$ts),
          as.double(.data$edited_ts)
        ), na.rm = TRUE),
        .by = "ts"
      ) |>
      dplyr::pull(.data$change_ts) |>
      max(na.rm = TRUE) |>
      as.POSIXct(
        origin = "1970-01-01",
        tz = "UTC"
      ) |>
      format(format = "%Y-%m-%d-%H%M%OS0%Z")

    threads_filename <- paste0(
      "data-raw/convos/threads-",
      ts_for_threads_filename,
      ".rds"
    )
    saveRDS(thread_changes, threads_filename)

    threads_all <- threads_old |>
      # Get rid of things that have changed.
      dplyr::anti_join(
        threads_new,
        by = c(
          "channel_id",
          "ts"
        )
      ) |>
      dplyr::bind_rows(threads_new) |>
      dplyr::arrange(.data$channel_id, .data$thread_ts, .data$ts)
    saveRDS(threads_all, "data-raw/convos/threads_all.rds")
    rm(
      ts_for_threads_filename,
      threads_filename,
      threads_all
    )
  }

  rm(
    convos_all,
    ts_for_filename,
    convos_filename,
    convos_old_thread_info,
    convos_with_reply_changes,
    threads_new,
    threads_old,
    threads_old_compare,
    common_columns,
    thread_changes
  )
}

rm(
  channels,
  convos_new,
  convos_old,
  convos_old_compare,
  convo_changes
)

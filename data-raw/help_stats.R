if ("reply_count" %in% colnames(convos_tbl)) {
  convos_tbl$reply_count <- tidyr::replace_na(
    convos_tbl$reply_count, 0L
  )
}
if ("reply_users_count" %in% colnames(convos_tbl)) {
  convos_tbl$reply_users_count <- tidyr::replace_na(
    convos_tbl$reply_users_count, 0L
  )
}

threads_nested <- threads_all |>
  tidyr::nest(.by = "thread_ts", .key = "replies")

convos_tbl <- convos_tbl |>
  dplyr::left_join(threads_nested, by = "thread_ts")

help_convos <- convos_tbl |>
  dplyr::inner_join(
    channels |>
      dplyr::select("channel_id", "channel_name") |>
      dplyr::filter(stringr::str_starts(.data$channel_name, "help-")),
    by = "channel_id"
  ) |>
  dplyr::filter(is.na(subtype)) |>
  dplyr::mutate(
    message_datetime = lubridate::as_datetime(as.double(ts)),
    latest_reply_datetime = lubridate::as_datetime(as.double(latest_reply)),
    message_year = lubridate::year(message_datetime)
  ) |>
  dplyr::select(
    "channel_id",
    "channel_name",
    "user",
    "ts",
    "text",
    "thread_ts",
    "reply_count",
    "reply_users_count",
    "latest_reply",
    "reply_users",
    "reactions",
    "replies",
    "message_datetime",
    "latest_reply_datetime",
    "message_year"
  )

year_counts <- help_convos |>
  dplyr::count(message_year)
year_counts
tibble::tibble(
  message_year = c(2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024),
  n = c(37L, 568L, 907L, 1819L, 2198L, 1650L, 975L, 928L)
)

mentor_channel_id <- "GAJ8D7YKA"
mentor_ids <- slack_conversations_members(mentor_channel_id)

has_reaction <- function(rxnses, posters, target_reactions) {
  purrr::map2_lgl(
    rxnses, posters,
    \(rxns, poster) {
      if (is.null(rxns)) return(FALSE)
      any(
        purrr::map2_lgl(
          rxns$name, rxns$users,
          \(rxn, reactors) {
            rxn %in% target_reactions && any(c(poster, mentor_ids) %in% reactors)
          }
        )
      )
      # is.null(rxns) || rxns |>
      #   tidyr::unnest_longer("users") |>
      #   dplyr::filter(
      #     name %in% c("heavy_check_mark", "question-answered", "white_check_mark"),
      #     users %in% c(poster, mentor_ids)
      #   ) |>
      #   nrow() |>
      #   as.logical()
    }
  )
}

help_convos |>
  dplyr::arrange(.data$message_year) |>
  dplyr::mutate(
    has_replies = .data$reply_count != 0,
    tagged_answered = has_reaction(
      .data$reactions,
      .data$user,
      c("heavy_check_mark", "question-answered", "white_check_mark")
    ),
    tagged_thread = has_reaction(
      .data$reactions,
      .data$user,
      c("thread", "reply")
    ),
    tagged_nevermind = has_reaction(
      .data$reactions,
      .data$user,
      c("question-nevermind", "octagonal_sign", "nevermind")
    )
  ) |>
  dplyr::filter(!tagged_thread, !tagged_nevermind) |>
  dplyr::summarize(
    .by = message_year,
    messages = dplyr::n(),
    has_replies = sum(reply_count != 0),
    p_has_replies = has_replies/messages * 100,
    tagged_answered = sum(tagged_answered),
    p_tagged_answered = tagged_answered/messages * 100,
  )

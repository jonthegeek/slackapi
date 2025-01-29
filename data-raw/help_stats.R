pkgload::load_all(".", helpers = FALSE, attach_testthat = FALSE)

channels <- conversations_list(
  types = "public_channel",
  exclude_archived = TRUE
)

convos_all <- readRDS("data-raw/convos/convos_all.rds")
threads_all <- readRDS("data-raw/convos/threads_all.rds")

if ("reply_count" %in% colnames(convos_all)) {
  convos_all$reply_count <- tidyr::replace_na(
    convos_all$reply_count, 0L
  )
}
if ("reply_users_count" %in% colnames(convos_all)) {
  convos_all$reply_users_count <- tidyr::replace_na(
    convos_all$reply_users_count, 0L
  )
}

threads_nested <- threads_all |>
  tidyr::nest(.by = "thread_ts", .key = "replies")

convos_all <- convos_all |>
  dplyr::left_join(threads_nested, by = "thread_ts")

help_convos <- convos_all |>
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
# tibble::tibble(
#   message_year = c(2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024),
#   n = c(37L, 568L, 907L, 1819L, 2198L, 1650L, 975L, 928L)
# )

mentor_channel_id <- "GAJ8D7YKA"
mentor_ids <- conversations_members(mentor_channel_id)

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

answer_tags <- help_convos |>
  dplyr::arrange(.data$message_year) |>
  dplyr::mutate(
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
  dplyr::mutate(
    has_replies = .data$reply_count != 0,
    tagged_answered = has_reaction(
      .data$reactions,
      .data$user,
      c("heavy_check_mark", "question-answered", "white_check_mark")
    ),
    asker_replied_last = purrr::map2_lgl(
      .data$user, .data$replies, \(this_user, these_replies) {
        if (!NROW(these_replies)) {
          return(TRUE)
        }
        last_replier <- these_replies |>
          dplyr::arrange(.data$ts) |>
          tail(1) |>
          dplyr::pull(.data$user)
        last_replier == this_user
      }
    ),
    tagged_more_info = has_reaction(
      .data$reactions,
      .data$user,
      c("speech_balloon", "question-more-info")
    ),
    waiting_for_asker = !.data$tagged_answered & .data$tagged_more_info & !.data$asker_replied_last
  )

answer_stats <- answer_tags |>
  dplyr::summarize(
    .by = message_year,
    messages = dplyr::n(),
    has_replies = sum(.data$reply_count != 0),
    p_has_replies = has_replies/messages * 100,
    tagged_answered = sum(.data$tagged_answered),
    p_tagged_answered = tagged_answered/messages * 100,
    tagged_waiting_op = sum(.data$waiting_for_asker),
    p_waiting_op = tagged_waiting_op/messages * 100,
    p_waiting_us = 100 - p_tagged_answered - p_waiting_op
  ) |>
  dplyr::select("message_year", "messages", "p_has_replies", "p_tagged_answered", "p_waiting_op", "p_waiting_us")

answer_stats

answerable <- answer_tags |>
  dplyr::filter(
    message_datetime > lubridate::now() - lubridate::days(90),
    !tagged_answered,
    !waiting_for_asker
  ) |>
  dplyr::mutate(url = glue::glue("https://dslcio.slack.com/archives/{channel_id}/p{ts}")) |>
  dplyr::select(channel_name, reply_count, url)

answerable

target_n <- 1L
answerable |>
  dplyr::slice(target_n) |>
  dplyr::pull(url) |>
  browseURL()

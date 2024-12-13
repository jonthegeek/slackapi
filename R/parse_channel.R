.parse_channel <- function(results) {
  tibblify::tibblify(
    results,
    spec = .slack_response_channel_spec(),
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

.slack_response_channel_spec <- function() {
  tspec_df(
    channel_id = tib_chr("id"),
    channel_name = tib_chr("name", required = FALSE),
    tib_lgl("is_im", .required = FALSE),
    tib_lgl("is_mpim", required = FALSE),
    tib_lgl("is_private", required = FALSE),
    channel_created_ts = tib_int("created", .required = FALSE),
    tib_lgl("is_archived", .required = FALSE),
    tib_lgl("is_general", required = FALSE),
    channel_name_normalized = tib_chr("name_normalized", required = FALSE),
    tib_lgl("is_shared", required = FALSE),
    tib_lgl("is_org_shared", .required = FALSE),
    tib_lgl("is_pending_ext_shared", required = FALSE),
    tib_unspecified("pending_shared", required = FALSE),
    tib_chr("context_team_id", .required = FALSE),
    updated_ts = tib_dbl("updated", .required = FALSE),
    tib_unspecified("parent_conversation", required = FALSE),
    tib_chr("creator", required = FALSE),
    tib_lgl("is_ext_shared", required = FALSE),
    tib_variant("shared_team_ids", required = FALSE),
    tib_unspecified("pending_connected_team_ids", required = FALSE),
    tib_lgl("is_member", required = FALSE),
    tib_row(
      "topic", .required = FALSE,
      topic_value = tib_chr("value", required = FALSE),
      topic_creator = tib_chr("creator", required = FALSE),
      topic_last_set_ts = tib_int("last_set", required = FALSE),
    ),
    tib_row(
      "purpose", .required = FALSE,
      purpose_value = tib_chr("value", required = FALSE),
      purpose_creator = tib_chr("creator", required = FALSE),
      purpose_last_set_ts = tib_int("last_set", required = FALSE),
    ),
    tib_row(
      "properties", .required = FALSE,
      tib_row(
        "canvas", .required = FALSE,
        canvas_file_id = tib_chr("file_id", required = FALSE),
        canvas_is_empty = tib_lgl("is_empty", required = FALSE),
        canvas_quip_thread_id = tib_chr("quip_thread_id", required = FALSE),
      ),
      tib_df(
        "tabs", .required = FALSE,
        tabs_id = tib_chr("id"),
        tabs_label = tib_chr("label", .required = FALSE),
        tabs_type = tib_chr("type", .required = FALSE),
        tabs_data = tib_row(
          "data", .required = FALSE,
          tib_chr("folder_bookmark_id", required = FALSE),
        ),
      ),
      tib_df(
        "tabz", .required = FALSE,
        tabz_id = tib_chr("id"),
        tabz_type = tib_chr("type", .required = FALSE),
        tabz_label = tib_chr("label", required = FALSE),
        tabz_data = tib_row(
          "data", .required = FALSE,
          tib_chr("folder_bookmark_id", required = FALSE),
        ),
      ),
      tib_row(
        "posting_restricted_to", .required = FALSE,
        posting_restricted_to_type = tib_variant("type", required = FALSE),
      ),
      tib_row(
        "threads_restricted_to", .required = FALSE,
        threads_restricted_to_type = tib_variant("type", required = FALSE),
      ),
    ),
    tib_variant("previous_names", required = FALSE),
    tib_int("num_members", required = FALSE),
    last_read_ts = tib_chr("last_read", required = FALSE),
    tib_lgl("is_open", required = FALSE),
    tib_dbl("priority", required = FALSE),
    im_other_user = tib_chr("user", required = FALSE),
    is_im_user_deleted = tib_lgl("is_user_deleted", required = FALSE),
  )
}

.parse_members <- function(resp) {
  results <- httr2::resp_body_json(resp)$members
  tibblify::tibblify(
    results,
    spec = .slack_response_members_spec(),
    unspecified = "list"
  )
}

.slack_response_members_spec <- function() {
  tspec_df(
    user_id = tib_chr("id"),
    tib_chr("team_id", required = FALSE),
    user_name = tib_chr("name", required = FALSE),
    is_deleted = tib_lgl("deleted", required = FALSE),
    user_color = tib_chr("color", required = FALSE),
    real_name = tib_chr("real_name", required = FALSE),
    time_zone = tib_chr("tz", required = FALSE),
    time_zone_label = tib_chr("tz_label", required = FALSE),
    time_zone_offset_seconds = tib_int("tz_offset", required = FALSE),
    tib_row(
      "profile", .required = FALSE,
      profile_title = tib_chr("title", required = FALSE),
      tib_chr("phone", required = FALSE),
      tib_chr("skype", required = FALSE),
      profile_real_name = tib_chr("real_name", required = FALSE),
      tib_chr("real_name_normalized", required = FALSE),
      tib_chr("display_name", required = FALSE),
      tib_chr("display_name_normalized", required = FALSE),
      profile_fields = tib_unspecified("fields", required = FALSE),
      tib_chr("status_text", required = FALSE),
      tib_chr("status_emoji", required = FALSE),
      tib_df(
        "status_emoji_display_info", .required = FALSE,
        status_emoji_name = tib_chr("emoji_name", required = FALSE),
        status_emoji_display_url = tib_chr("display_url", required = FALSE),
        status_emoji_unicode = tib_chr("unicode", required = FALSE)
      ),
      status_expiration_ts = tib_int("status_expiration", required = FALSE),
      tib_chr("avatar_hash", required = FALSE),
      profile_image_original = tib_chr("image_original", required = FALSE),
      profile_image_is_custom = tib_lgl("is_custom_image", required = FALSE),
      profile_image_24 = tib_chr("image_24", required = FALSE),
      profile_image_32 = tib_chr("image_32", required = FALSE),
      profile_image_48 = tib_chr("image_48", required = FALSE),
      profile_image_72 = tib_chr("image_72", required = FALSE),
      profile_image_192 = tib_chr("image_192", required = FALSE),
      profile_image_512 = tib_chr("image_512", required = FALSE),
      profile_image_1024 = tib_chr("image_1024", required = FALSE),
      tib_chr("status_text_canonical", required = FALSE),
      profile_team = tib_chr("team", required = FALSE),
      tib_chr("huddle_state", required = FALSE),
      tib_int("huddle_state_expiration_ts", required = FALSE),
      tib_chr("first_name", required = FALSE),
      tib_chr("last_name", required = FALSE),
      tib_chr("pronouns", required = FALSE),
      profile_who_can_share_contact_card = tib_chr("who_can_share_contact_card", required = FALSE),
      profile_api_app_id = tib_chr("api_app_id", required = FALSE),
      tib_lgl("always_active", required = FALSE),
      profile_bot_id = tib_chr("bot_id", required = FALSE)
    ),
    tib_lgl("is_admin", required = FALSE),
    tib_lgl("is_owner", required = FALSE),
    tib_lgl("is_primary_owner", required = FALSE),
    tib_lgl("is_restricted", required = FALSE),
    tib_lgl("is_ultra_restricted", required = FALSE),
    tib_lgl("is_bot", required = FALSE),
    tib_lgl("is_app_user", required = FALSE),
    user_updated_ts = tib_int("updated", required = FALSE),
    tib_lgl("is_email_confirmed", required = FALSE),
    tib_lgl("has_2fa", required = FALSE),
    tib_chr("who_can_share_contact_card", required = FALSE),
    user_locale = tib_chr("locale", required = FALSE),
    tib_lgl("is_invited_user", required = FALSE),
    tib_chr("two_factor_type", required = FALSE),
    tib_lgl("is_forgotten", required = FALSE)
  )
}

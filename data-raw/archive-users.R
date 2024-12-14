pkgload::load_all(".", helpers = FALSE, attach_testthat = FALSE)

users <- slack_users_list(include_locale = TRUE) |>
  tidyr::unnest(profile) |>
  dplyr::select(
    -"team_id",
    -"profile_team",
    -"profile_real_name",
    -"profile_image_24",
    -"profile_image_32",
    -"profile_image_48",
    -"profile_image_72",
    -"profile_image_192",
    -"profile_image_512",
    -"profile_image_1024",
    -"profile_who_can_share_contact_card",
    -"is_forgotten" # Overlaps 100% with is_deleted
  )

users_old <- readRDS("data-raw/users/users_all.rds")
users_old_compare <- users_old |>
  # I don't think this *can* happen, but just to be sure.
  dplyr::filter(!is.na(.data$user_updated_ts)) |>
  dplyr::select(
    "user_id",
    "user_updated_ts"
  )

user_changes <- users |>
  dplyr::anti_join(users_old_compare, by = c("user_id", "user_updated_ts"))

if (nrow(user_changes)) {
  saveRDS(users, "data-raw/users/users_all.rds")

  ts_for_filename <- max(
    user_changes$user_updated_ts,
    na.rm = TRUE
  ) |>
    as.double() |>
    as.POSIXct(
      origin = "1970-01-01",
      tz = "UTC"
    ) |>
    format(format = "%Y-%m-%d-%H%M%OS0%Z")
  users_filename <- paste0("data-raw/users/users-", ts_for_filename, ".rds")

  saveRDS(user_changes, users_filename)
}

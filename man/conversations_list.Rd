% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/paths-conversations-conversations_list.R
\name{conversations_list}
\alias{conversations_list}
\alias{req_conversations_list}
\title{Get conversations list}
\usage{
conversations_list(
  exclude_archived = FALSE,
  per_req = 200L,
  team_id = NULL,
  types = c("public_channel", "private_channel", "mpim", "im"),
  max_reqs = Inf,
  max_tries_per_req = 3,
  token = Sys.getenv("SLACK_API_TOKEN")
)

req_conversations_list(
  exclude_archived = FALSE,
  per_req = 200L,
  team_id = NULL,
  types = c("public_channel", "private_channel", "mpim", "im"),
  token = Sys.getenv("SLACK_API_TOKEN")
)
}
\arguments{
\item{exclude_archived}{(\code{logical}) Set to \code{TRUE} to exclude archived
channels from the list.}

\item{per_req}{(\code{integer}) The maximum number of items to return. Fewer than
the requested number of items may be returned, even if the end of the list
hasn't been reached. Must be an integer under 1000.}

\item{team_id}{(\code{character}) Encoded team id to list channels in, required if
token belongs to org-wide app.}

\item{types}{(\code{character}) Mix and match channel types by providing a vector
of any combination of \code{public_channel}, \code{private_channel}, \code{mpim}, \code{im}.}

\item{max_reqs}{(\code{integer}) The maximum number of separate requests to
perform. Passed on to \code{\link[nectar:req_perform_opinionated]{nectar::req_perform_opinionated()}}.}

\item{max_tries_per_req}{(\code{integer}) The maximum number of times to attempt
each individual request. Passed on to \code{\link[nectar:req_perform_opinionated]{nectar::req_perform_opinionated()}}.}

\item{token}{(\code{character}) A bearer token provided by Slack. A later
enhancement will add the ability to generate this token. Slack token are
long-lasting, and should be carefully guarded.}
}
\value{
\code{conversations_list()}: A tibble of information about channels and
channel-like conversations.

\code{req_conversations_list()}: A \code{httr2_request} request object to list
all channels in a Slack team.
}
\description{
Lists all channels in a Slack team.
}

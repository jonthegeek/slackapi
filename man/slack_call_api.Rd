% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/010-call.R
\name{slack_call_api}
\alias{slack_call_api}
\title{Call the Slack Web API}
\usage{
slack_call_api(
  path,
  query = list(),
  body = NULL,
  method = NULL,
  pagination = c("none", "cursor"),
  max_results = Inf,
  max_reqs = Inf,
  token = Sys.getenv("SLACK_API_TOKEN"),
  call = rlang::caller_env()
)
}
\arguments{
\item{path}{The route to an API endpoint. Optionally, a list or character
vector with the path as one or more unnamed arguments (which will be
concatenated with "/") plus named arguments to \code{\link[glue:glue]{glue::glue()}} into the
path.}

\item{query}{An optional list or character vector of parameters to pass in
the query portion of the request. Can also include a \code{.multi} argument to
pass to \code{\link[httr2:req_url]{httr2::req_url_query()}} to control how elements containing
multiple values are handled.}

\item{body}{An object to use as the body of the request. If any component of
the body is a path, pass it through \code{\link[fs:path]{fs::path()}} or otherwise give it the
class "fs_path" to indicate that it is a path.}

\item{method}{If the method is something other than GET or POST, supply it.
Case is ignored.}

\item{pagination}{(\code{character}) The pagination scheme to use. Currently either
"none" (the default) or "cursor" (a scheme that uses \code{cursor}-based
pagination; see \href{https://api.slack.com/apis/pagination}{Pagination through collections} in the Slack API
documentation. We do not currently support "Classic pagination".}

\item{max_results}{(\code{integer} or \code{Inf}) The maximum number of results to
return. Note that slightly more results may be returned if \code{max_results} is
not evenly divisible by 100.}

\item{max_reqs}{The maximum number of separate requests to perform. Passed to
the max_reqs argument of \code{\link[httr2:req_perform_iterative]{httr2::req_perform_iterative()}} when \code{next_req}
is supplied. The default \code{2} should likely be changed to \code{Inf} after you
validate the function.}

\item{token}{(\code{character}) A bearer token provided by Slack. A later
enhancement will add the ability to generate this token. Slack token are
long-lasting, and should be carefully guarded.}

\item{call}{The execution environment of a currently
running function, e.g. \code{caller_env()}. The function will be
mentioned in error messages as the source of the error. See the
\code{call} argument of \code{\link[rlang:abort]{abort()}} for more information.}
}
\value{
A tibble with the results of the API call.
}
\description{
Generate and perform request to a Slack Web API method.
}

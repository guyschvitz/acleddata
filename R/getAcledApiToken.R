#' Get ACLED API Access Token
#'
#' Retrieve an access token for the ACLED API using your account credentials.
#' The access token is required for all API calls to retrieve ACLED data.
#'
#' @param username Character. Email address associated with a valid ACLED account.
#' @param password Character. Password for the ACLED account.
#' @param url Character. URL of API endpoint to retrieve a token.
#'   Defaults to "https://acleddata.com/oauth/token".
#'
#' @return A list containing the elements "access_token" and "refresh_token".
#'   The access_token should be used for subsequent API calls.
#'
#' @examples
#' \dontrun{
#' # Get access token using your ACLED credentials
#' token.response <- getAcledApiToken(
#'   username = "your_email@example.com",
#'   password = "your_password"
#' )
#'
#' # Extract the access token for use in other functions
#' access.token <- token.response$access_token
#' }
#' @importFrom httr2 request req_body_multipart req_headers req_retry req_perform resp_status resp_body_json resp_body_string
#' @importFrom curl has_internet
#' @export
getAcledApiToken <- function(username, password, url = "https://acleddata.com/oauth/token") {
  # Input validation
  if (is.null(username) || !nzchar(username)) {
    stop("`username` must be a non-empty character string.")
  }
  if (is.null(password) || !nzchar(password)) {
    stop("`password` must be a non-empty character string.")
  }
  if (!curl::has_internet()) {
    stop("No internet connection detected.")
  }

  # Prepare request body
  body.list <- list(
    username = username,
    password = password,
    grant_type = "password",
    client_id = "acled"
  )

  tryCatch({
    resp.obj <- httr2::request(url) |>
      httr2::req_body_multipart(!!!body.list) |>
      httr2::req_headers(
        `Content-Type` = "multipart/form-data",
        `User-Agent` = "acled-r-client/0.1"
      ) |>
      httr2::req_retry(max_tries = 3) |>
      httr2::req_perform()

    status.code <- httr2::resp_status(resp.obj)
    if (status.code < 200 || status.code >= 300) {
      # Try to extract API error message if present
      msg <- NA_character_
      suppressWarnings({
        msg <- tryCatch(
          httr2::resp_body_string(resp.obj),
          error = function(e) NA_character_
        )
      })
      stop("Authentication failed (HTTP ", status.code, "): ",
           if (!is.na(msg) && nzchar(msg)) msg else "Invalid credentials")
    }

    resp.ls <- httr2::resp_body_json(resp.obj, simplifyVector = TRUE)

    if (is.null(resp.ls$access_token)) {
      stop("Authentication response missing access_token. Check your credentials.")
    }

    return(resp.ls)

  }, error = function(e) {
    stop("Authentication request failed: ", conditionMessage(e))
  })
}

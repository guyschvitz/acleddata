#' Get ACLED API Region Codes
#'
#' Retrieve all available ACLED region codes that can be used to filter API queries by region.
#' These codes correspond to different geographic regions in the ACLED database.
#'
#' @return A named numeric vector of API region codes where names are region names
#'   and values are the corresponding numeric codes.
#'
#' @examples
#' \dontrun{
#' # Get all available region codes
#' regions <- getAcledRegionCodes()
#' print(regions)
#'
#' # Use a specific region code in API query
#' data <- getAcledData(
#'   access.token = "your_token_here",
#'   region = regions["Western Africa"]
#' )
#' }
#'
#' @export
getAcledRegionCodes <- function() {
  region.codes <- c(
    "Western Africa" = 1,
    "Middle Africa" = 2,
    "Eastern Africa" = 3,
    "Southern Africa" = 4,
    "Northern Africa" = 5,
    "South Asia" = 7,
    "Southeast Asia" = 9,
    "Middle East" = 11,
    "Europe" = 12,
    "Caucasus and Central Asia" = 13,
    "Central America" = 14,
    "South America" = 15,
    "Caribbean" = 16,
    "East Asia" = 17,
    "North America" = 18,
    "Oceania" = 19,
    "Antarctica" = 20
  )

  return(region.codes)
}

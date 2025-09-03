#' Get ACLED API Interaction Codes
#'
#' Retrieve all available ACLED interaction codes that can be used to filter API queries
#' by actor interactions. These codes represent different types of interactions between
#' actors in conflict events, including single-actor events and dyadic interactions.
#'
#' @param as.vector Logical: Return result as named vector (TRUE) or as data.frame (FALSE)? Default: TRUE
#'
#' @return A named numeric vector of API interaction codes where names are interaction
#'   descriptions and values are the corresponding numeric codes.
#'
#' @examples
#' \dontrun{
#' # Get all available interaction codes
#' interactions <- getAcledInterCodes()
#' print(interactions)
#'
#' # Use specific interaction codes in API query
#' data <- getAcledData(
#'   access.token = "your_token_here",
#'   interaction = interactions["State forces-Civilians"],
#'   country = "Syria"
#' )
#'
#' # Filter for state forces only events
#' state.events <- getAcledData(
#'   access.token = "your_token_here",
#'   interaction = interactions["State forces only"],
#'   year = "2023"
#' )
#' }
#'
#' @export
getAcledInterCodes <- function(as.vector = TRUE) {
  inter.codes <- c(
    "State forces only" = 10,
    "State forces-State forces" = 11,
    "State forces-Rebel group" = 12,
    "State forces-Political militia" = 13,
    "State forces-Identity militia" = 14,
    "State forces-Rioters" = 15,
    "State forces-Protesters" = 16,
    "State forces-Civilians" = 17,
    "State forces-External/Other forces" = 18,
    "Rebel group only" = 20,
    "Rebel group-Rebel group" = 22,
    "Rebel group-Political militia" = 23,
    "Rebel group-Identity militia" = 24,
    "Rebel group-Rioters" = 25,
    "Rebel group-Protesters" = 26,
    "Rebel group-Civilians" = 27,
    "Rebel group-External/Other forces" = 28,
    "Political militia only" = 30,
    "Political militia-Political militia" = 33,
    "Political militia-Identity militia" = 34,
    "Political militia-Rioters" = 35,
    "Political militia-Protesters" = 36,
    "Political militia-Civilians" = 37,
    "Political militia-External/Other forces" = 38,
    "Identity militia only" = 40,
    "Identity militia-Identity militia" = 44,
    "Identity militia-Rioters" = 45,
    "Identity militia-Protesters" = 46,
    "Identity militia-Civilians" = 47,
    "Identity militia-External/Other forces" = 48,
    "Rioters only" = 50,
    "Rioters-Rioters" = 55,
    "Rioters-Protesters" = 56,
    "Rioters-Civilians" = 57,
    "Rioters-External/Other forces" = 58,
    "Protesters only" = 60,
    "Protesters-Protesters" = 66,
    "Protesters-Civilians" = 67,
    "Protesters-External/Other forces" = 68,
    "Civilians only" = 70,
    "Civilians-Civilians" = 77,
    "External/Other forces-Civilians" = 78,
    "External/Other forces only" = 80,
    "External/Other forces-External/Other forces" = 88
  )

  if(!as.vector){
    inter.codes <- data.frame("inter_name" = names(inter.codes),
                              "inter_code" = unname(inter.codes))
  }

  return(inter.codes)
}

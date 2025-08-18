#' Get Latest Available ACLED Data End Date
#'
#' Helper function to calculate the end date of the most recent ACLED dataset based on ACLED's release schedule.
#' ACLED releases data every Wednesday covering events up until the previous Friday.
#' This function returns the Friday end date of the latest available dataset.
#'
#' @param date Date or character. The reference date (default: Sys.Date()).
#'   If character, should be in YYYY-MM-DD format.
#'
#' @return A Date object representing the Friday end date of the latest available ACLED dataset.
#'
#' @details
#' ACLED Release Schedule:
#' - Data is released every Wednesday
#' - Each release covers events up until the previous Friday
#' - If today is Monday/Tuesday, the latest dataset ends on Friday of last week
#' - If today is Wednesday or later, the latest dataset ends on Friday of this week
#'
#' @examples
#' # Get latest available ACLED end date from today
#' getAcledEndDate()
#'
#' # Check what data would be available on specific dates
#' getAcledEndDate("2024-03-11")  # Monday - previous Friday
#' getAcledEndDate("2024-03-13")  # Wednesday - this Friday
#' getAcledEndDate("2024-03-15")  # Friday - this Friday
#'
#' @export
getAcledEndDate <- function(date = Sys.Date()) {
  # Convert to Date if character
  if (is.character(date)) {
    date <- as.Date(date)
  }

  # Get day of week (0 = Sunday, 1 = Monday, ..., 5 = Friday, 6 = Saturday)
  day.of.week <- as.numeric(format(date, "%w"))

  # ACLED releases on Wednesday (3), covering up to previous Friday
  # If today is Mon/Tue (1-2): latest release was last Wed, covering Friday of last week
  # If today is Wed+ (3-0): latest release is this Wed, covering Friday of this week

  if (day.of.week %in% c(1, 2)) {
    # Monday or Tuesday: go to Friday of last week
    # First get to this week's Friday, then subtract 7 days
    days.to.friday <- ifelse(day.of.week >= 5, day.of.week - 5, day.of.week + 2)
    this.friday <- date - days.to.friday
    latest.friday <- this.friday - 7  # Previous week's Friday
  } else {
    # Wednesday through Sunday: go to Friday of this week
    days.to.friday <- ifelse(day.of.week >= 5, day.of.week - 5, day.of.week + 2)
    latest.friday <- date - days.to.friday
  }

  return(latest.friday)
}

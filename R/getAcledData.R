#' Get ACLED Data
#'
#' Retrieve data from the ACLED (Armed Conflict Location & Event Data Project) API
#' with support for various filters and query types including date ranges.
#'
#' @param access.token Character. Your ACLED API access token (required).
#' @param event.id.cnty Character. Event identifier by country (LIKE filter).
#' @param event.date Character. Event date in YYYY-MM-DD format, or date range as YYYY-MM-DD|YYYY-MM-DD (= filter).
#' @param year Character or numeric. Year(s), or year range as YYYY|YYYY (= filter).
#' @param time.precision Numeric. Time precision level 1-3 (= filter).
#' @param disorder.type Character. Type of disorder (LIKE filter).
#' @param event.type Character. Type of event (LIKE filter).
#' @param sub.event.type Character. Sub-event type (LIKE filter).
#' @param actor1 Character. Primary actor 1 (LIKE filter).
#' @param assoc.actor.1 Character. Associated actor 1 (LIKE filter).
#' @param inter1 Character or numeric. Actor 1 interaction code (= filter).
#' @param actor2 Character. Primary actor 2 (LIKE filter).
#' @param assoc.actor.2 Character. Associated actor 2 (LIKE filter).
#' @param inter2 Character or numeric. Actor 2 interaction code (= filter).
#' @param interaction Character or numeric. Interaction code (= filter).
#' @param inter.num Numeric. Interaction number format 0 or 1 (= filter).
#' @param civilian.targeting Character. Civilian targeting indicator (LIKE filter).
#' @param iso Numeric. ISO country code (= filter).
#' @param region Numeric. Region code (= filter).
#' @param country Character. Country name (= filter).
#' @param admin1 Character. Administrative level 1 (LIKE filter by default).
#' @param admin2 Character. Administrative level 2 (LIKE filter by default).
#' @param admin3 Character. Administrative level 3 (LIKE filter by default).
#' @param location Character. Location name (LIKE filter).
#' @param latitude Numeric. Latitude coordinate (= filter).
#' @param longitude Numeric. Longitude coordinate (= filter).
#' @param geo.precision Numeric. Geographic precision level 1-3 (= filter).
#' @param source Character. Source information (LIKE filter).
#' @param source.scale Character. Source scale (LIKE filter).
#' @param notes Character. Event notes (LIKE filter).
#' @param fatalities Numeric. Number of fatalities (= filter).
#' @param tags Character. Event tags (LIKE filter).
#' @param timestamp Numeric or character. Timestamp filter - number or YYYY-MM-DD format (= filter).
#' @param export.type Character. Export type "dyadic" or "monadic" (= filter).
#' @param population Character. Population data "TRUE" or "full" (= filter).
#' @param event.date.where Character. Query type for event.date ("=", ">", "<", "BETWEEN").
#' @param year.where Character. Query type for year ("=", ">", "<", "BETWEEN").
#' @param fatalities.where Character. Query type for fatalities ("=", ">", "<", "BETWEEN").
#' @param timestamp.where Character. Query type for timestamp ("=", ">", "<", "BETWEEN").
#' @param admin1.where Character. Query type for admin1 ("=" or "LIKE").
#' @param admin2.where Character. Query type for admin2 ("=" or "LIKE").
#' @param admin3.where Character. Query type for admin3 ("=" or "LIKE").
#' @param fields Character. Specific fields to return, separated by "|".
#' @param limit Numeric. Maximum number of rows to return per page (default: 5000).
#' @param format Character. Response format (currently forced to "json").
#'
#' @return A data.frame containing the requested ACLED data.
#'
#' @examples
#' \dontrun{
#' # Get access token first
#' token.response <- getAcledApiToken("your_email@example.com", "your_password")
#' access.token <- token.response$access_token
#'
#' # Get events from France between 2021 and 2023
#' data <- getAcledData(
#'   access.token = access.token,
#'   country = "France",
#'   year = "2021|2023",
#'   year.where = "BETWEEN"
#' )
#'
#' # Get events from specific date range
#' data <- getAcledData(
#'   access.token = access.token,
#'   event.date = "2021-01-01|2021-12-31",
#'   event.date.where = "BETWEEN",
#'   country = "France"
#' )
#'
#' getAcledData(
#' access.token = access.token,
#' event.type = "Prot",  # Partial match ('Protests', LIKE filter)
#' country = "France",
#' year = "2023")
#'}
#' @importFrom httr2 request req_url_query req_headers req_retry req_perform resp_status resp_body_json resp_body_string
#' @importFrom dplyr bind_rows
#' @importFrom curl has_internet
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @export
getAcledData <- function(access.token,
                         # Event identifiers
                         event.id.cnty = NULL,
                         event.date = NULL,
                         year = NULL,
                         time.precision = NULL,
                         # Event classification
                         disorder.type = NULL,
                         event.type = NULL,
                         sub.event.type = NULL,
                         # Actors
                         actor1 = NULL,
                         assoc.actor.1 = NULL,
                         inter1 = NULL,
                         actor2 = NULL,
                         assoc.actor.2 = NULL,
                         inter2 = NULL,
                         interaction = NULL,
                         inter.num = NULL,
                         civilian.targeting = NULL,
                         # Geographic filters
                         iso = NULL,
                         region = NULL,
                         country = NULL,
                         admin1 = NULL,
                         admin2 = NULL,
                         admin3 = NULL,
                         location = NULL,
                         latitude = NULL,
                         longitude = NULL,
                         geo.precision = NULL,
                         # Source and notes
                         source = NULL,
                         source.scale = NULL,
                         notes = NULL,
                         # Impact and metadata
                         fatalities = NULL,
                         tags = NULL,
                         timestamp = NULL,
                         export.type = NULL,
                         population = NULL,
                         # Query type parameters (where clauses)
                         event.date.where = NULL,
                         year.where = NULL,
                         fatalities.where = NULL,
                         timestamp.where = NULL,
                         admin1.where = NULL,
                         admin2.where = NULL,
                         admin3.where = NULL,
                         # Query parameters
                         fields = NULL,
                         limit = 5000,
                         format = "json") {

  # ---- Input validation ----
  if (is.null(access.token) || !nzchar(access.token)) {
    stop("`access.token` must be a non-empty character string.")
  }

  # Enforce JSON parsing to avoid silent failures
  if (!identical(format, "json")) {
    warning("Only 'json' is supported for parsing; coercing `format` to 'json'.")
    format <- "json"
  }

  # Validate event.date format (single date or date range)
  if (!is.null(event.date) && !is.character(event.date)) {
    stop("`event.date` must be a character string.")
  }
  if (!is.null(event.date) && !grepl("^\\d{4}-\\d{2}-\\d{2}(\\|\\d{4}-\\d{2}-\\d{2})?$", event.date)) {
    stop("`event.date` must be in YYYY-MM-DD format or YYYY-MM-DD|YYYY-MM-DD for ranges.")
  }

  # Validate year format (single year or year range)
  if (!is.null(year)) {
    if (is.numeric(year)) {
      year <- as.character(year)
    }
    if (!is.character(year)) {
      stop("`year` must be character or numeric.")
    }
    if (!grepl("^\\d{4}(\\|\\d{4})?$", year)) {
      stop("`year` must be in YYYY format or YYYY|YYYY for ranges.")
    }
  }

  # Validate where clauses
  valid.where.types <- c("=", ">", "<", "BETWEEN", "LIKE")
  where.params <- list(
    event.date.where = event.date.where,
    year.where = year.where,
    fatalities.where = fatalities.where,
    timestamp.where = timestamp.where,
    admin1.where = admin1.where,
    admin2.where = admin2.where,
    admin3.where = admin3.where
  )

  for (param.name in names(where.params)) {
    param.value <- where.params[[param.name]]
    if (!is.null(param.value) && !param.value %in% valid.where.types) {
      stop("`", param.name, "` must be one of: ", paste(valid.where.types, collapse = ", "))
    }
  }

  # Other validations
  if (!is.null(latitude) && !is.numeric(latitude)) {
    stop("`latitude` must be numeric.")
  }
  if (!is.null(longitude) && !is.numeric(longitude)) {
    stop("`longitude` must be numeric.")
  }
  if (!is.null(time.precision) && (!is.numeric(time.precision) || !time.precision %in% 1:3)) {
    stop("`time.precision` must be numeric (1, 2, or 3).")
  }
  if (!is.null(geo.precision) && (!is.numeric(geo.precision) || !geo.precision %in% 1:3)) {
    stop("`geo.precision` must be numeric (1, 2, or 3).")
  }
  if (!is.null(limit) && (!is.numeric(limit) || limit < 1)) {
    stop("`limit` must be a positive number.")
  }
  if (!is.null(timestamp) && !(is.numeric(timestamp) || grepl("^\\d{4}-\\d{2}-\\d{2}$", timestamp))) {
    stop("`timestamp` must be numeric or a date string (YYYY-MM-DD).")
  }
  if (!is.null(inter.num) && (!is.numeric(inter.num) || !inter.num %in% c(0, 1))) {
    stop("`inter.num` must be 0 or 1.")
  }
  if (!is.null(export.type) && !export.type %in% c("dyadic", "monadic")) {
    stop("`export.type` must be 'dyadic' or 'monadic'.")
  }
  if (!is.null(population) && !population %in% c("TRUE", "full")) {
    stop("`population` must be 'TRUE' or 'full'.")
  }
  if (!curl::has_internet()) {
    stop("No internet connection detected.")
  }

  # ---- Setup API call ----
  base.url <- "https://acleddata.com/api/acled/read"

  query.params <- list(
    `_format` = format,
    key = access.token,               # ACLED commonly expects the key in the query
    event_id_cnty = event.id.cnty,
    event_date = event.date,
    year = year,
    time_precision = time.precision,
    disorder_type = disorder.type,
    event_type = event.type,
    sub_event_type = sub.event.type,
    actor1 = actor1,
    assoc_actor_1 = assoc.actor.1,
    inter1 = inter1,
    actor2 = actor2,
    assoc_actor_2 = assoc.actor.2,
    inter2 = inter2,
    interaction = interaction,
    inter_num = inter.num,
    civilian_targeting = civilian.targeting,
    iso = iso,
    region = region,
    country = country,
    admin1 = admin1,
    admin2 = admin2,
    admin3 = admin3,
    location = location,
    latitude = latitude,
    longitude = longitude,
    geo_precision = geo.precision,
    source = source,
    source_scale = source.scale,
    notes = notes,
    fatalities = fatalities,
    tags = tags,
    timestamp = timestamp,
    export_type = export.type,
    population = population,
    fields = fields,
    limit = limit,
    # Where clauses
    event_date_where = event.date.where,
    year_where = year.where,
    fatalities_where = fatalities.where,
    timestamp_where = timestamp.where,
    admin1_where = admin1.where,
    admin2_where = admin2.where,
    admin3_where = admin3.where
  )

  # ---- Function to query API and return parsed JSON ----
  getApiResponse <- function(url, params, token, retries = 3) {
    tryCatch({
      resp.obj <- httr2::request(url) |>
        httr2::req_url_query(!!!params) |>
        httr2::req_headers(
          Authorization = paste("Bearer", token),
          Accept = "application/json",
          `User-Agent` = "acled-r-client/0.1"
        ) |>
        httr2::req_retry(max_tries = retries) |>
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
        stop("API request failed (HTTP ", status.code, "): ",
             if (!is.na(msg) && nzchar(msg)) msg else "Unknown error")
      }

      body.parsed <- httr2::resp_body_json(resp.obj, simplifyVector = TRUE)

      if (is.null(body.parsed$data)) {
        stop("No data returned. Check your filters and ensure they are valid.")
      }

      return(body.parsed)
    }, error = function(e) {
      stop("API request failed: ", conditionMessage(e))
    })
  }

  # ---- Initial query ----
  query.params$page <- 1
  resp.ls <- getApiResponse(base.url, query.params, access.token)

  if (is.null(resp.ls$count) || is.null(resp.ls$total_count)) {
    stop("Unexpected response structure: missing `count` or `total_count`.")
  }

  nrows <- resp.ls$count
  total <- resp.ls$total_count

  # Early exit if no data
  if (nrows == 0 || total == 0) {
    warning("No data matched the specified filters.")
    return(data.frame())
  }

  n.pages <- ceiling(total / nrows)
  data.ls <- vector("list", length = n.pages)
  data.ls[[1]] <- resp.ls$data

  # Handle pagination if needed
  if (n.pages > 1) {
    message("Retrieving ", total, " records across ", n.pages, " pages...")
    if (interactive()) {
      pb <- utils::txtProgressBar(min = 1, max = n.pages, style = 3)
      utils::setTxtProgressBar(pb, 1)
    }

    for (i in 2:n.pages) {
      query.params$page <- i
      page.resp <- getApiResponse(base.url, query.params, access.token)
      data.ls[[i]] <- page.resp$data
      if (interactive()) {
        utils::setTxtProgressBar(pb, i)
      }
    }

    if (interactive()) {
      close(pb)
    }
  }

  # Combine all pages
  out.df <- dplyr::bind_rows(data.ls)
  out.df <- as.data.frame(out.df)

  if (nrow(out.df) == 0) {
    warning("No data returned after combining pages.")
  } else {
    message("Successfully retrieved ", nrow(out.df), " records.")
  }

  return(out.df)
}

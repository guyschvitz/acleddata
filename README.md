# acleddata

R client for the **new ACLED API (launched August 2025)**. Includes:

-   OAuth2 token retrieval
-   Lookups for **region** and **interaction** codes
-   A typed query wrapper for ACLED events with **WHERE** operators, **pagination**, and **field selection**

Note: ACLED data usage requires a valid myACLED account with full access rights. For more information, see: <https://acleddata.com/myacled-faqs>

------------------------------------------------------------------------

## Installation

``` r
remotes::install_github("guyschvitz/acleddata")
```

## Quick start

``` r
# 1) Authenticate (uses your ACLED login)
token.response <- getAcledApiToken(
  username = acled.user.email,
  password = acled.user.password
)

access.token <- token.response$access_token

# 2) Basic query: protests in France in 2023
fr.protest.df <- getAcledData(
  access.token = access.token,
  event.type   = "Prot",     # partial match (LIKE filter)
  country      = "France",
  year         = "2023"
)
```

## Function reference

### `getAcledApiToken(username, password, url = "https://acleddata.com/oauth/token")`

-   **Output:** list with access_token, refresh_token.

### `getAcledRegionCodes()`

-   **Output:** Named vector of ACLED region codes (names = region names, values = numeric codes).

### `getAcledInterCodes()`

-   **Output:** Named vector of ACLED interaction codes (names = interaction labels, values = numeric codes).

### `getAcledData(...)`

-   **Output:** A data.frame containing ACLED data.

-   **Key arguments:** filters (country, year, event.type, admin levels…), WHERE operators (\*\_where), fields, limit, export.type.

## Filter by date ranges

The `year` and `event_date` fields accept the following filters: `=, >, <, BETWEEN` for date ranges, you need to pass the start and end-date as a string concatenated by `|`. Note that by default, the ACLED API assumes filter type `=` for *year* and *event_date,* so you have to explicitly specify `BETWEEN` as the filter.

``` r

## Get all protest events in France in 2023
fr.protest1.df <- getAcledData(
  access.token = access.token,
  event.type   = "Protest",     # partial match (LIKE filter)
  country      = "France",
  year         = "2023"
)

## Get all protest events in France only in the years 2021 and 2023
fr.protest2.df <- getAcledData(
  access.token = access.token,
  event.type   = "Protest",     
  country      = "France",
  year         = "2021|2023"
)

## Get all protest events in France between 2021 and 2023
fr.protest3.df <- getAcledData(
  access.token = access.token,
  event.type   = "Protest",     
  country      = "France",
  year         = "2021|2023",
  year.where   = "BETWEEN"
)

## Get all protest events in France after January 1st 2021
fr.protests4.df <- getAcledData(
  access.token = access.token,
  event.type   = "Protest",     
  country      = "France",
  event.date   = "2021-01-01",
  event.date.where   = ">"
)
```

## Filter by region codes

You can filter data by ACLED numeric region codes. Use the helper function `getAcledRegionCodes` to look up numeric region codes.

``` r
region.codes.num <- getAcledRegionCodes()

# Example: use a region code in a query
wa.df <- getAcledData(
  access.token = access.token,
  region       = region.codes.num[["Western Africa"]],
  year         = "2024|2025",
  year.where   = "BETWEEN"
)
```

## Filter by interaction codes

You can also filter by interaction codes. Use the helper function `getAcledInterCodes` to look up numeric interaction codes. For more information on interaction codes, see: <https://acleddata.com/methodology/acled-codebook>

``` r
inter.codes.num <- getAcledInterCodes()
inter.codes.num
# e.g., "State forces-Civilians" = 17, "Protesters only" = 60, ...

# Example: state forces vs civilians in Syria
syr.state.civ.df <- getAcledData(
  access.token = access.token,
  country      = "Syria",
  interaction  = inter.codes.num[["State forces-Civilians"]],
  year         = "2023"
)
```

## Subset fields (faster, smaller responses)

You can limit the number of columns in the response dataset to limit data size and increase performance.

``` r
# Only fetch a minimal set of columns
fields.str <- paste(
  c("event_id_cnty", "event_date", "country", "admin1", "event_type", "sub_event_type",
    "actor1", "actor2", "fatalities", "iso", "latitude", "longitude"),
  collapse = "|"
)

mini.df <- getAcledData(
  access.token = access.token,
  country      = "Kenya",
  year         = "2024",
  fields       = fields.str
)
```

## Equality vs. LIKE on admin units

Some fields, like `admin1`, accept both `LIKE` filters for partial matches or `=` for exact matches.

``` r
# LIKE (partial string)
lagos.like.df <- getAcledData(
  access.token = access.token,
  country      = "Nigeria",
  admin1       = "Lago",          # matches "Lagos"
  admin1.where = "LIKE",
  year         = "2024"
)

# Exact match
lagos.eq.df <- getAcledData(
  access.token = access.token,
  country      = "Nigeria",
  admin1       = "Lagos",
  admin1.where = "=",
  year         = "2024"
)
```

## Dyadic vs. monadic exports

``` r
# Dyadic (actor1-actor2 structured)
dyadic.df <- getAcledData(
  access.token = access.token,
  country      = "Ethiopia",
  year         = "2024",
  export.type  = "dyadic"
)

# Monadic (one row per event)
monadic.df <- getAcledData(
  access.token = access.token,
  country      = "Ethiopia",
  year         = "2024",
  export.type  = "monadic"
)
```

## Pagination and `limit`

You can query up to 5000 rows of data at a time. The client automatically paginates.

``` r
# Query 5000 rows at a time
big.pull.df <- getAcledData(
  access.token = access.token,
  country      = "India",
  year         = "2024",
  limit        = 5000
)
```

## Using timestamps

ACLED applies incremental updates. The `timestamp` field indicates the exact date and time an event was last uploaded to the ACLED API, and can be used for filtering.

``` r
# Fetch events updated since a given date (YYYY-MM-DD)
updated.df <- getAcledData(
  access.token    = access.token,
  country         = "Ukraine",
  timestamp       = "2025-07-01",
  timestamp.where = ">"
)
```

## Citing ACLED

If you use ACLED data in a publication, please consult the citation guidelines: <https://acleddata.com/sites/default/files/wp-content-archive/uploads/dlm_uploads/2023/11/ACLED-Terms-of-Use-Attribution-Policy_Oct2023.pdf>

## License

MIT © 2025 Guy Schvitz

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/s2_list.R
\name{s2_list}
\alias{s2_list}
\title{Retrieve list of available S2 products.}
\usage{
s2_list(
  spatial_extent = NULL,
  tile = NULL,
  orbit = NULL,
  time_interval = c(Sys.Date() - 10, Sys.Date()),
  time_period = "full",
  level = "auto",
  server = "scihub",
  apihub = NA,
  service = "apihub",
  max_cloud = 100,
  availability = "ignore",
  output_type = "deprecated"
)
}
\arguments{
\item{spatial_extent}{A valid spatial object object of class \code{sf},
\code{sfc} or \code{sfg}}

\item{tile}{\verb{string array} Sentinel-2 Tiles to be considered string (5-length character)}

\item{orbit}{\verb{string array} Sentinel-2 orbit numbers to be considered}

\item{time_interval}{Dates to be considered, as a temporal vector (class \link{POSIXct} or
\link{Date}, or string in \code{YYYY-mm-dd} format) of length 1 (specific day) or 2 (time interval).}

\item{time_period}{(optional) Character:
\itemize{
\item "full" (default) means that all
the images included in the time window are considered;
\item "seasonal" means that only the single seasonal periods in the
window are used (i.e., with a time window from 2015-06-01 to
2017-08-31, the periods 2015-06-01 to 2015-08-31, 2016-06-01
to 2016-08-31 and 2017-06-01 to 2017-08-31 are considered).
}}

\item{level}{Character vector with one of the following:
- "auto" (default): check if level-2A is available on SciHub:
if so, list it; if not, list the corresponding level-1C
product
- "L1C": list available level-1C products
- "L2A": list available level-2A products}

\item{server}{The servers where archives are searched. Currently,
only \code{"scihub"} is supported (Google Cloud will be implemented in future).
In case of multiple values, they are used in order of priority.
If \code{availability = "check"}, products on LTA are always left as last choice.}

\item{apihub}{Path of the \code{apihub.txt} file containing credentials
of SciHub account.
If NA (default), the default location inside the package will be used.}

\item{service}{Character: it can be \code{"dhus"} or \code{"apihub"} (default),
in which cases the required service is forced instead that the one present
in the URLs passed through argument \code{s2_prodlist}.}

\item{max_cloud}{Integer number (0-100) containing the maximum cloud
level of the tiles to be listed (default: no filter).}

\item{availability}{Character argument, determining which products have
to be returned:
\itemize{
\item \code{"online"} : only archive names already available for download are returned;
\item \code{"lta"}: only archive names stored in the
\href{https://scihub.copernicus.eu/userguide/LongTermArchive}{Long Term Archive}
are returned;
\item \code{"check"}: all archive names are returned, checking if they are
available or not for download (see "Value" to know
how to distinguish each other);
\item \code{"ignore"} (default): all archive names are returned, without doing the check
(running the function is faster).
}}

\item{output_type}{Deprecated (use \code{as.data.table} to obtain a data.table).}
}
\value{
An object of class \link{safelist}.
The attribute \code{online} contains logical values: in case
\code{availability != "ignore"}, values are TRUE / FALSE for
products available for download / stored in the Long Term Archive;
otherwise, values are set to NA.
}
\description{
The function retrieves the list of available Sentinel-2
products satisfying given search criteria.
}
\note{
License: GPL 3.0
}
\examples{
\donttest{
pos <- sf::st_sfc(sf::st_point(c(9.85,45.81)), crs = 4326)
time_window <- as.Date(c("2016-05-01", "2017-07-30"))

# Full-period list
example_s2_list <- s2_list(
  spatial_extent = pos,
  tile = "32TNR",
  time_interval = time_window,
  orbit = "065"
)
print(example_s2_list)
# Print the dates of the retrieved products
safe_getMetadata(example_s2_list, "sensing_datetime")

# Seasonal-period list
example_s2_list <- s2_list(
  spatial_extent = pos,
  tile = "32TNR",
  time_interval = time_window,
  time_period = "seasonal"
)
print(example_s2_list)
# Print the dates of the retrieved products
safe_getMetadata(example_s2_list, "sensing_datetime")
}
}
\references{
L. Ranghetti, M. Boschetti, F. Nutini, L. Busetto (2020).
"sen2r": An R toolbox for automatically downloading and preprocessing
Sentinel-2 satellite data. \emph{Computers & Geosciences}, 139, 104473. DOI:
\href{https://doi.org/10.1016/j.cageo.2020.104473}{10.1016/j.cageo.2020.104473},
URL: \url{http://sen2r.ranghetti.info/}.
}
\author{
Lorenzo Busetto, phD (2019) \email{lbusett@gmail.com} - Inspired by
function \code{getSentinel_query} of package
\href{https://github.com/16EAGLE/getSpatialData}{\code{getSpatialData}} by J. Schwalb-Willmann

Luigi Ranghetti, phD (2019) \email{luigi@ranghetti.info}
}

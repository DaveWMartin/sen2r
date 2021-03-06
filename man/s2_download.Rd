% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/s2_download.R
\name{s2_download}
\alias{s2_download}
\title{Download S2 products.}
\usage{
s2_download(
  s2_prodlist = NULL,
  downloader = "builtin",
  apihub = NA,
  service = NA,
  tile = NULL,
  outdir = ".",
  order_lta = TRUE,
  overwrite = FALSE
)
}
\arguments{
\item{s2_prodlist}{Named character: list of the products to be downloaded,
in the format \code{safelist} (see \linkS4class{safelist}).
Alternatively, it can be the path of a JSON file exported by \link{s2_order}.}

\item{downloader}{Executable to use to download products
(default: "builtin"). Alternatives are "builtin" or "aria2"
(this requires aria2c to be installed).}

\item{apihub}{Path of the \code{apihub.txt} file containing credentials
of SciHub account.
If NA (default), the default location inside the package will be used.}

\item{service}{Character: it can be \code{"dhus"} or \code{"apihub"}, in which cases
the required service is forced instead that the one present in the URLs
passed through argument \code{s2_prodlist}.
If NA (default), the service present in the URLs is maintained.}

\item{tile}{Deprecated argument}

\item{outdir}{(optional) Full name of the existing output directory
where the files should be created (default: current directory).}

\item{order_lta}{Logical: if TRUE (default), products which are not available
for direct download are ordered from the Long Term Archive;
if FALSE, they are simply skipped.}

\item{overwrite}{Logical value: should existing output archives be
overwritten? (default: FALSE)}
}
\value{
Vector character with the list ot the output products
(being downloaded or already existing).
}
\description{
The function downloads S2 products.
Input filenames must be elements obtained with
\link{s2_list} function
(each element must be a URL, and the name the product name).
}
\note{
License: GPL 3.0
}
\examples{
\dontrun{
single_s2 <- paste0("https://scihub.copernicus.eu/apihub/odata/v1/",
  "Products(\'c7142722-42bf-4f93-b8c5-59fd1792c430\')/$value")
names(single_s2) <- "S2A_MSIL1C_20170613T101031_N0205_R022_T32TQQ_20170613T101608.SAFE"
# (this is equivalent to:
# single_s2 <- example_s2_list[1]
# where example_s2_list is the output of the example of the
# s2_list() function)

# Download the whole product
s2_download(single_s2, outdir=tempdir())

#' # Download the whole product - using aria2
s2_download(single_s2, outdir=tempdir(), downloader = "aria2")

# Download more products, ordering the ones stored in the Long Term Archive
pos <- sf::st_sfc(sf::st_point(c(-57.8815,-51.6954)), crs = 4326)
time_window <- as.Date(c("2018-02-21", "2018-03-20"))
list_safe <- s2_list(spatial_extent = pos, time_interval = time_window)
s2_download(list_safe, outdir=tempdir())
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
Luigi Ranghetti, phD (2020) \email{luigi@ranghetti.info}

Lorenzo Busetto, phD (2019) \email{lbusett@gmail.com}
}

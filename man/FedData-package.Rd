\name{FedData-package}
\alias{FedData-package}
\alias{FedData}
\docType{package}
\title{
Scripts to automate downloading geospatial data available from the several federated data sources
}
\description{
This package contains scripts to automate downloading geospatial data available from the several federated data sources (mainly sources maintained by the US Federal government). Currently, the package allows for retrieval of four datasets: 
\itemize{
\item The \href{http://ned.usgs.gov}{National Elevation Dataset} digital elevation models (1 and 1/3 arc-second; USGS)
\item The \href{http://nhd.usgs.gov}{National Hydrography Dataset} (USGS)
\item The \href{http://websoilsurvey.sc.egov.usda.gov/}{Soil Survey Geographic} (SSURGO) database from the National Cooperative Soil Survey (NCSS), which is led by the Natural Resources Conservation Service (NRCS) under the USDA, and
\item The \href{http://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/global-historical-climatology-network-ghcn}{Global Historical Climatology Network} (GHCN), coordinated by National Climatic Data Center at NOAA.
}

Additional data sources are in the works, including global DEM resources (ETOPO1, ETOPO5, ETOPO30, SRTM), global soils (HWSD), tree-ring records (ITRDB), MODIS satellite data products, the National Atlas (US), Natural Earth, PRISM, and WorldClim.
}
\details{
\tabular{ll}{
Package: \tab FedData\cr
Type: \tab FedData\cr
Version: \tab 1.0\cr
Date: \tab 2015-02-09\cr
License: \tab GPL-3\cr
}

This package is designed with the large-scale GIS use-case in mind: cases where the use of dynamic web-services is impractical due to the scale (spatial and/or temporal) of analysis. It functions primarily as a means of downloading tiled or otherwise spaticially-defined datasets; additionally, it can preprocess those datasets by extracting data within an area of interest (AoI), defined spatially. It relies heavily on the \pkg{sp}, \pkg{raster}, and \pkg{rgdal} packages, and requires three command line tools be installed by the user (and accesible through \code{\link{system}} calls in \emph{R}): \href{https://www.gnu.org/software/wget/}{wget} (for downloading with timestamping), \href{http://www.gdal.org}{\code{GDAL}} (for manipulating raster and vector spatial data), and \href{http://mdbtools.sourceforge.net}{mdbtools} (for extracting data from access databases).

There are three general types of methods available for each dataset (and others for particular datasets):

\tabular{ll}{
get...: \tab High-level function that allows the user to define an AoI ("template") and returns the dataset cropped/masked to the area of interest. Examples: getNED(template, ...), getNHD(template, ...), getNRCS(template, ...).\cr

extract...: \tab Mid-level functions that automate extraction of tabular data from databases (such as the SSURGO soils tabular data) that may or may not be linked to spatial data. Often called by "get" functions.\cr

download...: \tab Low-level functions that automate downloading of raw tabular and spatial data from databases. Downloading is done at the smallest data-unit of each dataset; e.g., 1x1 degree tiles for the NED, HUC4 subregions for the NHD, and Study Areas for the SSURGO soils data. Downloading is sometimes (but not always) performed with timestamping, such that source files are only downloaded if the remote files are more recent than the local files. Often called by "get" functions. Returns a local path to the downloaded file. \cr

}

Additionally, most functions can be forced to "start fresh" in downloading or processing data by specifying "force.redo=TRUE" in the function call.

}

\author{
R. Kyle Bocinsky <bocinsky@gmail.com>
}

\keyword{ package }

\references{

Gesch, D.B. (2007) The National Elevation Dataset, in Maune, D., ed., \emph{Digital Elevation Model Technologies and Applications: The DEM Users Manual}. 2nd Edition. American Society for Photogrammetry and Remote Sensing, Bethesda, Maryland.

Gesch, D., Oimoen, M., Greenlee, S., Nelson, C., Steuck, M., and Tyler, D. (2002) The National Elevation Dataset. \emph{Photogrammetric Engineering and Remote Sensing} 68(1):5--11.

Menne, M., Durre, I., Korzeniewski, B., McNeal, S., Thomas, K., Yin, X., Anthony, S., Ray, R., Vose, R., B.E.Gleason, and Houston, T. (2012) \emph{Global Historical Climatology Network-Daily (GHCN-Daily), Version 3}. \url{http://doi.org/10.7289/V5D21VHZ}.

Soil Survey Staff, Natural Resources Conservation Service, United States Department of Agriculture. Soil Survey Geographic (SSURGO) Database. Available online at \url{http://sdmdataaccess.nrcs.usda.gov/}.

}

\examples{
\dontrun{
install.packages("FedData")
library(FedData)

# Get a random contiguous USA county for testing
wgetDownload(
  "http://dds.cr.usgs.gov/pub/data/nationalatlas/countyp010g.shp_nt00934.tar.gz"
  ,destdir=getwd())

untar("./countyp010g.shp_nt00934.tar.gz")
county <- rgdal::readOGR(".","countyp010g")
county <- county[!(county$STATE %in% c("AK","VI","PR","HI")),]
county <- county[sample(1:length(county),1),]

# Get the NED (USA ONLY)
# Returns a raster
NED <- getNED(template=county,
  label=paste(county$STATE,'_',county$NAME, sep=''), res='1')

# Get the daily GHCN data (GLOBAL)
# Returns a list: the first element is the spatial locations of stations,
# and the second is a list of the stations and their daily data
GHCN.prcp <- getGHCNDaily(template=county, 
  label=paste(county$STATE,'_',county$NAME, sep=''), 
  elements=c('prcp'), 
  standardize=F)
  
GHCN.temp <- getGHCNDaily(template=county, 
  label=paste(county$STATE,'_',county$NAME, sep=''), 
  elements=c('tmin','tmax'), 
  standardize=T)

# Get the NHD (USA ONLY)
NHD <- getNHD(template=county, 
  label=paste(county$STATE,'_',county$NAME, sep=''))

# Get the NRCS SSURGO data (USA ONLY)
SSURGO <- getSSURGO(template=county, 
  label=paste(county$STATE,'_',county$NAME, sep=''))

}
}
#' Read netcdf (.nc) data from global inventaries
#'
#' @description Read data from global inventoris
#'
#' @return Matrix or raster
#'
#' @param file input file
#' @param version inventorie information
#' @param as_raster return a raster (defoult) or matrix
#' @param verbose display additional information
#'
#' @seealso \code{\link{rasterSource}} and \code{\link{gridInfo}}
#'
#' @export
#'
#' @import raster
#' @import ncdf4
#' @importFrom units as_units
#' 
#' @source read abbout EDGAR at http://edgar.jrc.ec.europa.eu
#'
#' @examples \dontrun{
#' # Do not run
#' d1     <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' d2     <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' print("download and untar EDGAR data from:")
#' print("http://edgar.jrc.ec.europa.eu/gallery.php?release=v431_v2&substance=NOx&sector=TRO")
#' nox    <- read("v431_v2_REFERENCE_NOx_2010_10_TRO.0.1x0.1.nc")
#' sp::spplot(nox, scales = list(draw=TRUE), xlab="Lat", ylab="Lon",main="NOx emissions from EDGAR")
#' nox_d1 <- rasterSource(nox,d1)
#' nox_d2 <- rasterSource(nox,d2)
#' image(nox_d1, main = "NOx emissions from transport from EDGAR 3.4.1 for d1")
#' image(nox_d2, main = "NOx emissions from transport from EDGAR 3.4.1 for d2")
#'}

read <- function(file, version = "EDGAR 4.3.1", as_raster = T, verbose = T){
  ed   <- ncdf4::nc_open(file)
  name <- names(ed$var)
  if(verbose) 
    print(paste0("reading ",name," (",version,") units are g m2 s-1 ..."))
  var  <- ncdf4::ncvar_get(ed,name)
  if(as_raster){
    var <- apply(var,1,rev)
    r <- raster::raster(x = 1000 * var,xmn=-180,xmx=180,ymn=-90,ymx=90)
    raster::crs(r) <- "+proj=longlat +ellps=GRS80 +no_defs"
    names(r)       <- name
    return(r)
  }else{
    var            <- units::as_units(1000 * var,"g m2 s-1")
    return(var)
  }
}
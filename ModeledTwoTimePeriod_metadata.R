title <- "Cumulative human impacts: pressure and cumulative impacts data (2008 and 2013, subset of pressures)"
creators <- data.frame(
    surname=c("Halpern", "Frazier", "Potapenko", "Casey", "Koenig", "Longo", "Lowndes", "Rockwood", "Selig", "Selkoe", "Walbridge"),
    given=c("Benjamin", "Melanie", "John", "Kenneth", "Kellee", "Catherine", "Julia", "Cotton", "Elizabeth", "Kimberly", "Shaun"),
    email=c("halpern@bren.ucsb.edu","frazier@nceas.ucsb.edu", 'potapenko@umail.ucsb.edu', 'kenneth.casey@noaa.gov', 'kkoenig@conservation.org',
            'longo@nceas.ucsb.edu', 'lowndes@nceas.ucsb.edu', 'rrockwood@ucsd.edu', 'eselig@conservation.org', 'selkoe@nceas.ucsb.edu', 
            'shaun.walbridge@gmail.com'),
    stringsAsFactors=FALSE)
abstract <- "This is a portion of the data used to calculate 2008 and 2013 cumulative human impacts  
in the publication: Halpern et al. 2015. Spatial and temporal changes in cumulative human impacts
on the world's ocean.  

Seven data packages are available for this
project: (1) supplementary data (habitat data and other files); (2) raw stressor data (2008 and 2013);  
(3) stressor data rescaled by one time period (2008 and 2013, scaled from 0-1); 
(4) stressor data rescaled by two time periods (2008 and 2013, scaled from 0-1); 
(5) pressure and cumulative impacts data (2013, all pressures);
(6) pressure and cumulative impacts data (2008 and 2013, subset of pressures updated for both time periods);
(7) change in pressures and cumulative impact (2008 to 2013).
All raster files are .tif format and coordinate reference system is mollweide wgs84.

This data package includes the 2013 pressure and final cumulative impacts data.  These data do not include pressures: 
sea level rise, ocean pollution, invasives, and shipping because data was not available for 2008.
These files should be used for comparisons of 2008 and 2013 data, but it is important to note that they do not include
all pressures. 
Pressure data was calculated for each stressor by: (1) multiplying the rescaled stressor (rescaled using the maximum value across both 2008 and 2013 data) 
by each habitat layer and the corresponding stressor/habitat
vulnerability score (for each stressor this generates: 20 rasters); (2) summing the resulting stressor/habitat/vulnerability rasters (generates 1 raster for each stressor);
(3) dividing by the number of habitats found in each raster cell layer.  The cumulative impacts was calculated by summing all the pressure rasters. 
For both 2008 and 2013, there are N=15 pressure rasters and N=1 cumulative impact raster."

methodDescription <- "For methods please refer to the paper."
geo_coverage <- geo_cov("Global", west=-180, east=180, north=90, south=-90)
temp_coverage <- temp_cov("2008", "2013")
TRUE

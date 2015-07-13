title <- "Cumulative human impacts: stressor data rescaled by one time period (2008 and 2013, scaled from 0-1)"
creators <- data.frame(
    surname=c("Halpern", "Frazier", "Potapenko", "Casey", "Koenig", "Longo", "Lowndes", "Rockwood", "Selig", "Selkoe", "Walbridge"),
    given=c("Benjamin", "Melanie", "John", "Kenneth", "Kellee", "Catherine", "Julia", "Cotton", "Elizabeth", "Kimberly", "Shaun"),
    email=c("halpern@bren.ucsb.edu","frazier@nceas.ucsb.edu", 'potapenko@umail.ucsb.edu', 'kenneth.casey@noaa.gov', 'kkoenig@conservation.org',
            'longo@nceas.ucsb.edu', 'lowndes@nceas.ucsb.edu', 'rrockwood@ucsd.edu', 'eselig@conservation.org', 'selkoe@nceas.ucsb.edu', 
            'shaun.walbridge@gmail.com'),
    stringsAsFactors=FALSE)
abstract <- "This is a portion of the data used to calculate 2008 and 2013 cumulative human impacts  
in: Halpern et al. 2015. Spatial and temporal changes in cumulative human impacts on the world's ocean.  

Seven data packages are available for this project:  
(1) supplementary data (habitat data and other files); 
(2) raw stressor data (2008 and 2013);  
(3) stressor data rescaled by one time period (2008 and 2013, scaled from 0-1); 
(4) stressor data rescaled by two time periods (2008 and 2013, scaled from 0-1); 
(5) pressure and cumulative impacts data (2013, all pressures);
(6) pressure and cumulative impacts data (2008 and 2013, subset of pressures updated for both time periods);
(7) change in pressures and cumulative impact (2008 to 2013).
All raster files are .tif format and coordinate reference system is mollweide wgs84.

Here is an overview of the calculations:
Raw stressor data -> rescaled stressor data (values between 0-1) -> 
pressure data (stressor data after adjusting for habitat/pressure vulnerability) -> 
cumulative impact (sum of pressure data) -> difference between 2008 and 2013 pressure and cumulative impact data. 

This data package includes 2008 and 2013 stressor data rescaled to have values between 0 and 1. 
These values were calculated for each stressor/year raster cell by first log10(x+1) transforming 
the data and then dividing by the highest raster cell value for each stressor/year.  There are N=18 
2008 rasters (preceded by rescaled_2008_one_) and N=19 2013 rasters (preceded by rescaled_2013_one_).  
There is no sea level rise raster for 2008."

methodDescription <- "For methods please refer to the paper."
geo_coverage <- geo_cov("Global", west=-180, east=180, north=90, south=-90)
temp_coverage <- temp_cov("2008", "2013")
TRUE

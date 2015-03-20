# Upload geospatial files from a directory to a DataONE node
#
# Iterate over the subdirectories, each of which should contain one or more subdirectories
# that contain a data layer in a directory with its ancillary files.  Each top-level directory
# will be saved as a data package, and will contain a data entity for each of the second-level
# subdirectores, which will be uploaded as zip archvies.  In each top-level directory, we will
# search for a text file with metadata (title, creator(s), spatial extent, temporal extent,
# abstract, keywords, license), and use that to create overall dataset metadata.
#
# Matt Jones 2015-02-09

# Download and save permissions file
# https://cilogon.org/?skin=DataONE
# choose google
# launch java file and save file
# file.remove("../../../tmp/x509up_u1009")
# file.copy(from="x509up_u1009", to= "../../../tmp")

# To see file (replace ID with the data package ID): 
# https://dev.nceas.ucsb.edu/knb/d1/mn/v1/meta/urn:uuid:c432b7da-ba91-455b-9fa6-c5af8c24c5d5
  # http://dev.nceas.ucsb.edu/#view/urn:uuid:6bea95cc-f53e-44e6-a59f-500439e59fb5

library(dataone)
library(datapackage)
library(uuid)
library(XML)
library(EML)
library(digest)
library(dplyr)

#' Iterate over the data sets in a directory.
#' This function is passed a directory \code{'d'}, which contains a set of subdirectories,
#' each of which represents a data set. For each subdirectory, zip up the contents, generate
#' a new identifier, upload the zipfile to a repository, and add it to a DataPackage for
#' later inclusion in the dataset. Once all of the datasets are uploaded, source the associated
#' "metadata.R" file in each directory, use this to populate an EML metadata description, and
#' upload the EML and the associated DataPackage to the repository.

upload_datasets <- function(d, mn, assignDOI=FALSE, metadataFile="SupportingData_metadata.R", accessRules=NA) {
    savewd <- getwd()
    
    # Create a DataPackage to track all of the data objects that are created
    dp <- DataPackage()
    node <- "urn:node:mnTestKNB"
    cm <- CertificateManager()
    user <- showClientSubject(cm)

    #for(i in 1:length(d$package)){
    for(i in 1:2){
      #i=2
      package_data <- d$location[i]
      print(paste("Processing ", package_data))

    if(d$type[i]=="tif"){  
      setwd(package_data)
    # List all of the directories, each should represent one data object
    format <- "application/zip"  
  
    if(d$file_num[i]>1){  #if there is only one type of file in the folder grab the first one
    do_list <- list.files(pattern=".tif")
    do_list <- unique(sub("^([^.]*).*", "\\1", do_list))
    } else {do_list <- list.files(pattern=".tif")
            do_list <- unique(sub("^([^.]*).*", "\\1", do_list))[1]
    }
    
    #do_list <- list.dirs(".", full.names=FALSE, recursive=FALSE)
    for (do in do_list) {
      #do='ocean_mask' ## when i=3 above
      #do='beach_lzw'     ##when i=1 above
      # do='oil_rigs'  ## when i=2 above and package = RawData
        prefix=d$prefix[i]
        suffix=d$suffix[i]
    
      if(!(d$gsub1[i]=="")){  ## if there is info in the gsub variable of the pressures_data_organization.csv, it will replace some of the text in the file name to make more readable
        zipfile <- paste0(prefix, gsub(d$gsub1[i],'', do), suffix, ".zip")
      } else{zipfile <- paste0(prefix, do, suffix, ".zip")
      }
      
      if(d$file_num[i]>1){do <- list.files(pattern=do)  #if there is only one type of data, just include all data in the file
      } else {do <- list.files()
      }
        zip(zipfile, do)
        fq_zipfile <- normalizePath(zipfile)
  
        # Generate a unique identifier for the object
        identifier <- paste0("urn:uuid:", UUIDgenerate())

        # upload data zip to the data repository
        identifier <- upload_object(mn, zipfile, identifier, format, accessRules=accessRules)
        
        # Create a DataObject and add it to the DataPackage for tracking
        data_object <- new("DataObject", id=identifier, format=format, user=user, mnNodeId=node, filename=fq_zipfile)
        addData(dp, data_object)

        # TODO: add identifier to list of uploaded objects
        message(paste("Uploaded: ", identifier))

        # clean up
        unlink(zipfile)
    } # end of zipping .tif files for: (do in do_list)
    } # end of .tif data type: if(d$type=="tif")
    
    if(d$type[i]=="csv"){
      format <- "csv"  
      setwd(package_data)        
      # Generate a unique identifier for the object
      identifier <- paste0("urn:uuid:", UUIDgenerate())
      fileName <- d$filename[i]
      # upload data zip to the data repository
      identifier <- upload_object(mn, fileName, identifier, format, accessRules=accessRules)
      fq_file <- normalizePath(fileName)
      
      # Create a DataObject and add it to the DataPackage for tracking
      data_object <- new("DataObject", id=identifier, format=format, user=user, mnNodeId=node, filename=fq_file)
      addData(dp, data_object)
      
      # TODO: add identifier to list of uploaded objects
      message(paste("Uploaded: ", identifier))
      } # end of csv
    
    setwd("~/upload-datasets")
    } # end of going through files: for(i in 1:length(d$package))

    # create metadata for the directory
    mdfile <- paste0("~/upload-datasets/", metadataFile)
    success <- source(mdfile, local=FALSE)

    # Generate a unique identifier for the object
    if (assignDOI) {
        metadata_id <- generateIdentifier(mn, "DOI")
        # TODO: check if we actually got one, if not then error
        system <- "doi"
    } else {
        metadata_id <- paste0("urn:uuid:", UUIDgenerate())
        system <- "uuid"
    }

#    eml <- make_eml(metadata_id, system, title, creators, methodDescription, geo_coverage, temp_coverage)
    eml <- make_eml(metadata_id, system, title, creators, methodDescription, geo_coverage, temp_coverage, dp, mn@endpoint)
    eml_xml <- as(eml, "XMLInternalElementNode")
    #print(eml_xml)
    eml_file <- tempfile()
    saveXML(eml_xml, file = eml_file)

    # upload metadata to the repository
    return_id <- upload_object(mn, eml_file, metadata_id, "eml://ecoinformatics.org/eml-2.1.1", accessRules=accessRules)
    message(paste0("Uploaded metadata with id: ", return_id))

    # create and upload package linking the data files and metadata
    data_id_list <- getIdentifiers(dp)
    mdo <- new("DataObject", id=metadata_id, filename=eml_file, format="eml://ecoinformatics.org/eml-2.1.1", user=user, mnNodeId=node)
    addData(dp, mdo)
    unlink(eml_file)
    insertRelationship(dp, subjectID=metadata_id, objectIDs=data_id_list)
    tf <- tempfile()
    serialization_id <- paste0("urn:uuid:", UUIDgenerate())
    status <- serializePackage(dp, tf, id=serialization_id)
    return_id <- upload_object(mn, tf, serialization_id, "http://www.openarchives.org/ore/terms", accessRules=accessRules)
    message(paste0("Uploaded data package with id: ", return_id))
    unlink(tf)

    # Revert back to our calling directory
    setwd(savewd)
}

#' Create a geographic coverage element from a description and bounding coordinates
geo_cov <- function(geoDescription, west, east, north, south) {
    bc <- new("boundingCoordinates", westBoundingCoordinate=west, eastBoundingCoordinate=east, northBoundingCoordinate=north, southBoundingCoordinate=south)
    geoDescription="Southeast Alaska"
    gc <- new("geographicCoverage", geographicDescription=geoDescription, boundingCoordinates=bc)
    return(gc)
}

temp_cov <- function(begin, end) {
    bsd <- new("singleDateTime", calendarDate=begin)
    b <- new("beginDate", bsd)
    esd <- new("singleDateTime", calendarDate=end)
    e <- new("endDate", esd)
    rod <- new("rangeOfDates", beginDate=b, endDate=e)
    temp_coverage <- new("temporalCoverage", rangeOfDates=rod)
    return(temp_coverage)
}

cov <- function(gc, tempc) {
    coverage <- new("coverage", geographicCoverage=gc, temporalCoverage=tempc)
    return(coverage)
}

#' Create a minimal EML document.
#' Creating EML should be more complete, but this minimal example will suffice to create a valid document.
#make_eml <- function(id, system, title, creators, methodDescription=NA, geo_coverage=NA, temp_coverage=NA) {
    #dt <- eml_dataTable(dat, description=description)
make_eml <- function(id, system, title, creators, methodDescription=NA, geo_coverage=NA, temp_coverage=NA, datapackage=NA, endpoint=NA) {
  #dt <- eml_dataTable(dat, description=description)
  oe_list <- as(list(), "ListOfotherEntity")
  
  if (!is.na(datapackage)) {
    for (id in getIdentifiers(datapackage)) {
      print(paste("Creating entity for ", id, sep=" "))
      current_do <- getMember(datapackage, id)
      oe <- new("otherEntity", entityName=basename(current_do@filename), entityType="application/zip")
      oe@physical@objectName <- basename(current_do@filename)
      oe@physical@size <- current_do@sysmeta@size
      if (!is.na(endpoint)) {
        oe@physical@distribution@online@url <- paste(endpoint, id, sep="/")
      }
      f <- new("externallyDefinedFormat", formatName="ESRI Arc/View ShapeFile")
      df <- new("dataFormat", externallyDefinedFormat=f)
      oe@physical@dataFormat <- df
      oe_list <- c(oe_list, oe)
    }
  }
  
creator <- new("ListOfcreator", lapply(as.list(with(creators, paste(given, " ", surname, " ", "<", email, ">", sep=""))), as, "creator"))
    ds <- new("dataset",
              title = title,
              abstract = abstract,
              creator = creator,
              contact = as(creator[[1]], "contact"),
              #coverage = new("coverage"),
              pubDate = as.character(Sys.Date()),
              #dataTable = c(dt),
              otherEntity = as(oe_list, "ListOfotherEntity")
              #methods = new("methods"))
             )
    if (!is.na(methodDescription)) {
        ms <- new("methodStep", description=methodDescription)
        listms <- new("ListOfmethodStep", list(ms))
        ds@methods <- new("methods", methodStep=listms)
    }
    ds@coverage <- cov(geo_coverage, temp_coverage)
    eml <- new("eml",
              packageId = id,
              system = system,
              dataset = ds)
    return(eml)
}

#' Upload an object to a DataONE repository
upload_object <- function(mn, filename, newid, format, public=TRUE, replicate=FALSE, accessRules=NA) {

    # Ensure the user is logged in before the upload
    cm <- CertificateManager()
    user <- showClientSubject(cm)
    isExpired <- isCertExpired(cm)

    # Create SystemMetadata for the object
    size <- file.info(filename)$size
    sha1 <- digest(filename, algo="sha1", serialize=FALSE, file=TRUE)
    sysmeta <- new("SystemMetadata", identifier=newid, formatId=format, size=size, submitter=user, rightsHolder=user, checksum=sha1, originMemberNode=mn@identifier, authoritativeMemberNode=mn@identifier)
    sysmeta@replicationAllowed <- replicate
    sysmeta@numberReplicas <- 2
    sysmeta@preferredNodes <- list("urn:node:mnUCSB1", "urn:node:mnUNM1", "urn:node:mnORC1")
    if (public) {
        sysmeta <- addAccessRule(sysmeta, "public", "read")
    }

    if(!all(is.na(accessRules))) {
      sysmeta <- addAccessRule(sysmeta, accessRules)
    }

    # Upload the data to the MN using create(), checking for success and a returned identifier
    created_id <- create(mn, newid, filename, sysmeta)
#    if (is.null(created_id) | !grepl(newid, xmlValue(xmlRoot(created_id)))) {
     if (is.null(created_id) || !grepl(newid, xmlValue(xmlRoot(created_id)))) {
        # TODO: Process the error
        message(paste0("Error on returned identifier: ", created_id))
        return(newid)
    } else {
        return(newid)
    }
}


##### start of generating the data:

allFiles <- read.csv("pressures_data_organization.csv", stringsAsFactors=FALSE)

## Package: SupportingData 
setwd("~/upload-datasets")
packageData <- "SupportingData"
d <- allFiles %>%
  filter(package==packageData) 
#%>%
#  filter(data != "habitat_x_pressure")  ## for now, need to figure out how to load this

#' main method to iterate across directories, uploading each data set
    cn <- CNode("STAGING2")                     # Use Testing repository
    mn <- getMNode(cn, "urn:node:mnTestKNB")    # Use Testing repository
    #cn <- CNode()                               # Use Production repository
    #mn <- getMNode(cn, "urn:node:KNB")          # Use Production repository

    # Set permissions so that any member of chi-collaborators has read access and mfrazier has
    # every access: "changePermission" includes "read" and "write".
    # Note: We have to explicitly set access for mfrazer (KNB id) because data is submitted using
    # the DataONE id and that uid is used for the 'rightsholder'. With the permission 'changePermission',
    # mfrazier can change each dataset to 'public "read"' in the future.
    accessRules <- data.frame(subject=c("cn=chi-collaborators,o=unaffiliated,dc=ecoinformatics,dc=org", 
                                        "uid=frazier,o=unaffiliated,dc=ecoinformatics,dc=org"), 
                              permission=c("read", 
                                           "changePermission"))

upload_datasets(d, mn, assignDOI=FALSE, metadataFile=paste0(packageData, "_metadata.R"), accessRules=accessRules)

# last run: https://dev.nceas.ucsb.edu/#view/urn:uuid:db921899-ff75-44d6-a029-519560aa884c


## Package: RawData 
setwd("~/upload-datasets")
packageData <- "RawData"
d <- allFiles %>%
  filter(package==packageData) 
#%>%
#  filter(data != "habitat_x_pressure")  ## for now, need to figure out how to load this

#' main method to iterate across directories, uploading each data set
cn <- CNode("STAGING2")                     # Use Testing repository
mn <- getMNode(cn, "urn:node:mnTestKNB")    # Use Testing repository
#cn <- CNode()                               # Use Production repository
#mn <- getMNode(cn, "urn:node:KNB")          # Use Production repository

# Set permissions so that any member of chi-collaborators has read access and mfrazier has
# every access: "changePermission" includes "read" and "write".
# Note: We have to explicitly set access for mfrazer (KNB id) because data is submitted using
# the DataONE id and that uid is used for the 'rightsholder'. With the permission 'changePermission',
# mfrazier can change each dataset to 'public "read"' in the future.
accessRules <- data.frame(subject=c("cn=chi-collaborators,o=unaffiliated,dc=ecoinformatics,dc=org", 
                                    "uid=frazier,o=unaffiliated,dc=ecoinformatics,dc=org"), 
                          permission=c("read", 
                                       "changePermission"))

upload_datasets(d, mn, assignDOI=FALSE, metadataFile=paste0(packageData, "_metadata.R"), accessRules=accessRules)
## last run: https://dev.nceas.ucsb.edu/#view/urn:uuid:13b1c22e-9142-4d31-a659-b739068595b4


#' global.R
#'
#' This script initializes the shared environment for the RxGen project. It sets up 
#' common configurations, imports libraries, defines global variables, and sources 
#' reusable functions for both the Shiny UI and API endpoints.
#'
#' @details
#' - Loads required libraries for all components.
#' - Defines constants, file paths, and database configurations.
#' - Sources shared function files from the `src/` directory.
#' - Ensures consistency across different entry points like `shiny::runApp()` and `/annotate` API.
#'
#' @author Sam Seatt
#' @date 2024-11-18

library(yaml)
library(shiny)
library(DBI)
library(RPostgres)
library(VariantAnnotation)
# library(dplyr)
library(httr)
library(jsonlite)

# Database connection configuration
connect_to_db <- function() {
  config <- yaml::read_yaml("config/database.yml")
  con <- dbConnect(
    RPostgres::Postgres(),
    dbname = config$database,
    host = config$host,
    port = config$port,
    user = config$user,
    password = config$password
  )
  return(con)
}

# File path for queued VCF files
VCF_FOLDER <- "~/projects/vitaledge/data/loader/queued"

# Source the pipeline scripts
source("src/process_vcf.R")
source("src/data_export.R")
source("src/write_annotations.R")
source("src/fetch_variant_drug_interactions.R")
source("shiny/server.R")
source("shiny/ui.R")

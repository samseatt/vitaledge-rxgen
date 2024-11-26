#' app.R
#'
#' This script serves as the entry point for the Shiny UI of the RxGen project.
#' It initializes the environment, sources the necessary UI and server components, 
#' and launches the Shiny application.
#'
#' @details
#' - Sources `global.R` for shared configurations, constants, and functions.
#' - Sources `ui.R` and `server.R` from the `shiny/` directory for the application logic.
#' - Uses `shinyApp()` to start the application.
#' - Provides an interactive interface for managing VCF annotation processes.
#'
#' @examples
#' # To launch the Shiny UI:
#' shiny::runApp() 
#' # or directly run this file in RStudio:
#' source("app.R")
#'
#' @author Sam Seatt
#' @date 2024-11-18
#'
source("shiny/launch_ui.R")


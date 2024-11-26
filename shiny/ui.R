#' @title User Interface Definition for RxGen Shiny Application
#' @description This file defines the user interface (UI) for the Shiny application
#' used in the RxGen pipeline. The UI provides administrators and analysts with
#' options to upload, view, and manage VCF file annotations and patient-related
#' pharmacogenomic data.
#'
#' @details
#' - The UI includes a file path input for selecting patient VCF files to process.
#' - Provides controls to trigger the annotation process and download results.
#' - Displays patient annotation data in an interactive table format.
#'
#' @usage Not called directly; sourced by the main Shiny application.
#' @seealso \code{shiny/ui.R}
#' @author Sam Seatt
#'
#' @examples
#' # This script is used as part of the Shiny application structure.
#' shinyApp(ui = ui, server = server)
#'
#' @export
#' 
shiny_config <- yaml::read_yaml("config/shiny_config.yml")

ui <- fluidPage(
  titlePanel("RxGen Admin Dashboard"),
  sidebarLayout(
    sidebarPanel(
      textInput("file_path", "VCF File Path", value = "~/projects/vitaledge/data/loader/queued/patient1.vcf"),
      textInput("patient_id", "Patient ID", value = "test_patient"),
      actionButton("process", "Start Annotation"),
      tableOutput("job_status")
    ),
    mainPanel(
      h3("Job Status"),
      tableOutput("status_table")
    )
  )
)

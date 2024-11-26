#' @title Server Logic for RxGen Shiny Application
#' @description This file implements the server logic for the Shiny application
#' used in the RxGen pipeline. It handles the interaction between user inputs 
#' from the UI and the underlying annotation process.
#' 
#' @details
#' - Observes user inputs such as file path selection and process trigger.
#' - Initiates the annotation process by calling the core `process_vcf()` function.
#' - Updates the displayed results dynamically in response to user actions.
#' - Enables results download in CSV format for the annotated patient data.
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

server <- function(input, output) {
  job_status <- reactiveVal(data.frame(job_id = character(), status = character()))

  observeEvent(input$process, {
    file_path <- input$file_path
    patient_id <- input$patient_id

    tryCatch({
      print("#### Calling process_vcf")
      process_vcf(file_path, patient_id)
      new_status <- data.frame(job_id = file_path, status = "Success")
      job_status(rbind(job_status(), new_status))
    }, error = function(e) {
      new_status <- data.frame(job_id = file_path, status = "Failed: " %>% e$message)
      job_status(rbind(job_status(), new_status))
    })
  })

  output$status_table <- renderTable({
    job_status()
  })
}

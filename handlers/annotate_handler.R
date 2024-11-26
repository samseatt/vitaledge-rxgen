#' Annotate VCF File for a Patient
#'
#' This function handles the `/annotate` API endpoint. It accepts a patient ID
#' and a file path to a VCF file, processes the annotations, and returns a
#' success or error response.
#'
#' @param req The HTTP request object.
#' @param res The HTTP response object.
#' @return A JSON response with the annotation status.
#'
#' @author Sam Seatt
#' @date 2024-11-18
#' @export
annotate_vcf <- function(req, res) {
  body <- jsonlite::fromJSON(req$postBody)

  file_path <- body$file_path
  patient_id <- body$patient_id

  tryCatch({
    message("Annotation process started for patient ID: ", patient_id)
    process_vcf(file_path, patient_id)  # Call the core processing function
    list(status = "success", message = "Annotation completed successfully.")
  }, error = function(e) {
    res$status <- 500
    list(status = "error", message = e$message)
  })
}

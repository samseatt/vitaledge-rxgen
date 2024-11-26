
# Write Annotations to Patient Annotations Table
write_patient_annotations <- function(patient_id, annotations, con) {
  # print("%%% write_patient_annotations called")
  if (nrow(annotations) == 0) {
    warning("No matching annotations found for the patient's VCF.")
    return()
  }

  # Add patient_id to the annotations data frame
  annotations$patient_id <- patient_id
  # print("%%% Inserting annotations into database:")
  # print(annotations)
  # print(str(annotations))
  # print(colnames(annotations))
  # print("List table from database:")
  # print(con)

  # Insert annotations into the patient_annotations table
  dbWriteTable(
    con,
    name = "patient_annotations",
    value = annotations,
    append = TRUE,
    row.names = FALSE
  )

  # message("Patient annotations successfully written to the database.")
}

#' Fetch drug interactions for a specific variant from PharmGKB
#' @param variant_id The rsID or variant symbol to query.
#' @return JSON response with drug interaction data or an error message.
#' @export
annotate_variant_interactions <- function(variant_id) {
  print("@@@@ annotate_variant_interactions called")
  result <- fetch_variant_drug_interactions(variant_id)
  
  if (is.null(result)) {
    return(list(status = "error", message = "No interactions found or API request failed."))
  }
  
  return(list(status = "success", data = result))
}

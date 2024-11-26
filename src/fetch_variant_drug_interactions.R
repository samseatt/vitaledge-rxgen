#' @title Fetch Variant Drug Interactions from PharmGKB
#' @description Queries the PharmGKB API to fetch drug interaction data for a specific variant (rsID).
#' 
#' @param variant_id The ID of the variant (e.g., rsID) to query.
#' @return A data frame containing drug interaction details for the queried variant, or NULL if not found.
#' 
#' @examples
#' fetch_variant_drug_interactions("rs123456")
#' 
#' @export
fetch_variant_drug_interactions <- function(variant_id) {
  print("%%%% fetch_variant_drug_interactions called.")
  
  # Construct the API URL
  response <- GET(
    url = "https://api.pharmgkb.org/v1/data/variant/",
    query = list(symbol = variant_id)  # Use `symbol` as the query parameter
  )
  
  # Check if the request was successful
  if (http_status(response)$category != "Success") {
    warning(paste("Failed to fetch data for variant:", variant_id))
    print(content(response, as = "text"))
    return(NULL)
  }
  
  # Parse the JSON response
  content <- fromJSON(content(response, as = "text"))
  
  # Check if the variant is found
  if (is.null(content$data) || length(content$data) == 0) {
    warning(paste("Variant not found in PharmGKB:", variant_id))
    return(NULL)
  }
  
  return(as.data.frame(content$data))
}

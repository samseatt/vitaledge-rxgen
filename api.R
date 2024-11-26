# api.R
# 
# This script defines and runs the RxGen API using Plumber. It initializes
# routes and handlers, sourcing them from modular files.
#
# @details
# - Sources `global.R` for shared configurations and helper functions.
# - Uses a router to define API endpoints modularly.
#
# @examples
# # To run the API:
# # In R console:
# # source("api.R")
# #
# @author Sam Seatt
# @date 2024-11-18

# Load necessary libraries
library(plumber)

# Source global configuration and handlers
source("global.R")
source("handlers/annotate_handler.R")
source("handlers/annotate_variant_interactions_handler.R")

api_config <- yaml::read_yaml("config/api_config.yml")

# Define and run the API
router <- Plumber$new()

router$handle("POST", "/annotate", annotate_vcf)

router$handle("GET", "/variant/interaction", function(variant_id) {
  annotate_variant_interactions(variant_id)
})

router$run(host = "0.0.0.0", port = 8000)

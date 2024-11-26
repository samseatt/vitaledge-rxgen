# Load necessary libraries
library(shiny)

# Source global configurations and utilities
source("global.R")  # Adjust the path as needed

# Source UI and server components
source("shiny/ui.R")    # Ensure the path is correct
source("shiny/server.R")

# Launch the Shiny application
port <- as.numeric(Sys.getenv("SHINY_PORT", unset = 3838))
host <- Sys.getenv("SHINY_HOST", unset = "0.0.0.0")
shinyApp(ui = ui, server = server, options = list(port = port, host = host))

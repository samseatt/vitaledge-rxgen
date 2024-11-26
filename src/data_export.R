
connect_to_db <- function(config_file = "config/database.yml") {
  # Load configuration
  config <- yaml::read_yaml(config_file)
  
  # Extract the development environment configuration
  db_config <- config$development
  
  # Debugging: Print the database configuration to verify correctness
  # print(db_config)
  
  # Connect to the database using the extracted configuration
  con <- dbConnect(
    RPostgres::Postgres(),
    dbname = db_config$database,
    host = db_config$host,
    port = db_config$port,
    user = db_config$username,
    password = db_config$password
  )
  
  return(con)
}



getwd()
ls()



update.packages(ask = FALSE)
installed.packages()[, c("Package", "Version")]
old.packages()


install.packages("renv")
renv::init()
renv::snapshot()
update.packages(ask = FALSE)
install.packages("BiocManager")
BiocManager::install()
packageVersion("renv")
packageVersion("BiocManager")
BiocManager::install(c("VariantAnnotation", "Biostrings", "DBI", "RPostgres", "shiny", "testthat"))

sessionInfo()
library(VariantAnnotation)
library(shiny)

print(head(vcf))

library(renv)
renv::restore()


con <- connect_to_db("config/database.yml")
print(con)
result <- query_pharmgkb("rs4961")

rs_ids <- process_vcf("~/projects/vitaledge/data/loader/queued/patient1.vcf")
print(rs_ids)

shiny::runApp()

source("api.R")

psql postgres
> \c vitaledge_datalake
> \dt
> SELECT * FROM patient_annotations LIMIT 10;

> CREATE DATABASE vitaledge_datalake;

postgresql://username:password@localhost:5432/vitaledge_datalake




# DOCUMENTATION ...

https://bioconductor.org/packages/release/bioc/vignettes/VariantAnnotation/inst/doc/VariantAnnotation.html





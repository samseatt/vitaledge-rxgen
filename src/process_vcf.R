library(VariantAnnotation)

process_vcf <- function(file_path, patient_id, batch_size = 50) {
  message("Processing VCF file: ", file_path)
  cat("Reading VCFs...")

  # Load VCF
  vcf <- VariantAnnotation::readVcf(file_path, genome = "hg19")
  cat(length(vcf), " VCFs read")

  con <- connect_to_db()  # Reuse the DB connection function
  cat("...Connected to database")

  # Define chunk size
  chunk_size <- 1000
  cat("...Applying PharmKGB annotations to VCFs in batches of ", chunk_size, ":")

  total_rows <- length(rowRanges(vcf))

  tryCatch({
    # Process in chunks
    for (start_row in seq(1, total_rows, by = chunk_size)) {
      end_row <- min(start_row + chunk_size - 1, total_rows)
      
      # Extract a chunk
      vcf_chunk <- vcf[start_row:end_row]
      
      # Access data for this chunk
      gr_chunk <- rowRanges(vcf_chunk)  # Genomic ranges
      info_chunk <- info(vcf_chunk)    # Info fields
      assay_chunk <- assay(vcf_chunk)  # Genotype data

      variants <- as.data.frame(gr_chunk)

      # print(paste("$$$$ chunked variants produced: ", length(variants)))
      # print("$$$$ Column names2:")
      # print(colnames(variants))
      
      # Extract rsIDs from the row names
      if (!is.null(rownames(variants))) {
        variants$ID <- rownames(variants)  # Add rsIDs as a new column named 'ID'
      } else {
        stop("VCF file does not contain row names for rsIDs.")
      }
      # print("$$$$ Column names2:")
      # print(colnames(variants))

      # Query database for matches
      query <- sprintf(
        "SELECT id AS annotation_id, drug_id, variant_haplotypes 
        FROM pharmacogenomic_annotations 
        WHERE variant_haplotypes IN (%s)",
        paste(sprintf("'%s'", variants$ID), collapse = ", ")
      )
      # print(paste("#### Query to get annotations: ", query))

      annotations <- dbGetQuery(con, query)

      # Rename column variant_haplotypes to variant_id
      colnames(annotations)[colnames(annotations) == "variant_haplotypes"] <- "variant_id"

      # Exclude id and timestamp as they are auto-generated
      annotations$id <- NULL
      annotations$timestamp <- NULL

      cat("|")
      if (nrow(annotations) > 0) {
        write_patient_annotations(patient_id, annotations, con)
        cat("|")
      } else {
        cat("*")
      }
    }
    cat("...Finished")
  }, finally = {
    # Close the connection after processing all batches
    dbDisconnect(con)
    cat("...Database disconnected...")
  })
  message("Processing completed for file: ", file_path)
}



  
  # variants <- as.data.frame(rowRanges(vcf))
  # print(paste("$$$$ variants produced: ", length(variants)))

  # print("$$$$ Column names:")
  # print(colnames(variants))
  # # if (!"ID" %in% colnames(variants)) {
  # #   stop("VCF file does not contain an ID column.")
  # # }
  
  # # Extract rsIDs from the row names
  # if (!is.null(rownames(variants))) {
  #   variants$ID <- rownames(variants)  # Add rsIDs as a new column named 'ID'
  # } else {
  #   stop("VCF file does not contain row names for rsIDs.")
  # }
  # print("$$$$ Column names:")
  # print(length(colnames(variants)))
  # print(colnames(variants))
  # print(head(variants))


  # # Extract variant IDs
  # print("$$$$ Extracting variants")
  # variant_ids <- variants$ID[!is.na(variants$ID)]
  # print(paste("$$$$ variants ids extracted: ", length(variant_ids)))

  # con <- connect_to_db()  # Reuse the DB connection function
  # print("%%% Database connected")

  # # Batch process
  # print(paste("Batching with batch size of", batch_size))

  # tryCatch({
  # # Loop over batches
  #   for (start_idx in seq(1, length(variant_ids), by = batch_size)) {
  #     end_idx <- min(start_idx + batch_size - 1, length(variant_ids))
  #     batch <- variant_ids[start_idx:end_idx]

    #   # Query database for matches
    #   query <- sprintf(
    #     "SELECT id AS annotation_id, drug_id, variant_haplotypes 
    #     FROM pharmacogenomic_annotations 
    #     WHERE variant_haplotypes IN (%s)",
    #     paste(sprintf("'%s'", batch), collapse = ", ")
    #   )
    #   print(paste("#### Query to get annotations: ", query))

    #   annotations <- dbGetQuery(con, query)

    #   # Rename column variant_haplotypes to variant_id
    #   colnames(annotations)[colnames(annotations) == "variant_haplotypes"] <- "variant_id"

    #   # Exclude id and timestamp as they are auto-generated
    #   annotations$id <- NULL
    #   annotations$timestamp <- NULL

    #   if (nrow(annotations) > 0) {
    #     write_patient_annotations(patient_id, annotations, con)
    #   }
    # }
  # }, finally = {
  #   # Close the connection after processing all batches
  #   dbDisconnect(con)
  #   print("%%% Database disconnected")
  # })
  # message("## Processing completed for file: ", file_path)
# }

library(testthat)

test_that("VCF processing works", {
  vcf_file <- "data/example.vcf"
  variants <- process_vcf(vcf_file)
  expect_true(nrow(variants) > 0)
  expect_true("chr" %in% colnames(variants))
})

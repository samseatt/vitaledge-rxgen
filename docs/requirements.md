### **VitalEdge RxGen - Requirements Document**

This **Requirements Document** defines the key features, constraints, and technical needs of the **VitalEdge RxGen** module. It ensures a clear roadmap for development, testing, and deployment, aligned with the broader goals of the **VitalEdge R Pipelines** and the **vitaledge_datalake**.

#### **Project Name**:  
**VitalEdge RxGen**  

#### **Repository Name**:  
`vitaledge-rxgen`

---

## **1. Purpose**

This requirements document defines the functional, non-functional, and system requirements for the **VitalEdge RxGen** module. RxGen processes genomic Variant Call Format (VCF) files, annotates variants with pharmacogenomic data, and stores the results in the **vitaledge_datalake** for further analysis. It also provides a Shiny-based interface for users to upload, query, and visualize annotations.

---

## **2. Functional Requirements**

### **2.1 Data Input**
1. **File Input**:
   - Accept VCF files for processing.
   - Support single-patient and multi-patient VCF formats.
2. **Validation**:
   - Ensure the VCF file adheres to standard specifications.
   - Validate that required metadata (e.g., sample ID, format version) is present.

---

### **2.2 Variant Parsing**
1. Parse and extract relevant variant information from the VCF file, including:
   - Chromosome.
   - Position.
   - Reference allele.
   - Alternate allele.
   - Variant ID (e.g., rsID).

2. Identify and classify variants (e.g., SNPs, indels).

---

### **2.3 Variant Annotation**
1. **Pharmacogenomic Annotation**:
   - Query PharmGKB for drug-gene interaction data.
     - Required fields:
       - Gene symbol.
       - Drug name.
       - Interaction type (e.g., metabolizer, response modifier).
       - Annotation source (e.g., PharmGKB, ClinVar).
   - Query ClinVar for:
     - Clinical significance (e.g., pathogenic, benign).
     - Associated conditions.

2. Support multiple annotation sources to enrich variant data.

---

### **2.4 Data Transformation and Storage**
1. **Data Transformation**:
   - Normalize and standardize parsed and annotated data for storage.
   - Map extracted information to the target schema in the **vitaledge_datalake**.

2. **Database Schema**:
   - Store processed results in a dedicated table:
     ```sql
     CREATE TABLE pharmacogenomic_annotations (
         id SERIAL PRIMARY KEY,
         patient_id UUID NOT NULL,
         variant_id TEXT NOT NULL,
         gene_symbol TEXT NOT NULL,
         drug TEXT NOT NULL,
         interaction_type TEXT,
         clinical_significance TEXT,
         annotation_source TEXT,
         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
     );
     ```

3. **Error Handling**:
   - Handle database connection failures gracefully.
   - Log processing and storage errors for troubleshooting.

---

### **2.5 Visualization and Reporting**
1. **Interactive Shiny App**:
   - Provide an interface for:
     - Uploading VCF files.
     - Viewing and querying annotated variants.
     - Exporting data as CSV or JSON.

2. **Visualization Features**:
   - Display key metrics, such as:
     - Number of annotated variants.
     - Drug-gene interaction summaries.
   - Support basic filtering (e.g., by gene, drug, or clinical significance).

3. **Report Generation**:
   - Allow users to download reports summarizing annotated data.

---

## **3. Non-Functional Requirements**

### **3.1 Scalability**
- Support batch processing for large multi-sample VCF files.
- Handle increasing data volume and database size efficiently.

### **3.2 Performance**
- Process single-patient VCF files within 5 minutes on standard hardware.
- Return query results in the Shiny app with minimal latency (<2 seconds for typical queries).

### **3.3 Integration**
- Integrate seamlessly with the **vitaledge_datalake**.
- Ensure compatibility with existing schemas and future extensions.

### **3.4 Reusability**
- Implement modular R scripts using shared utilities from `vitaledge-r-pipe`.
- Ensure components are reusable across other pipelines (e.g., variant parsing, API querying).

### **3.5 Security**
- Encrypt sensitive patient data during processing and transmission.
- Enforce role-based access control for Shiny app features.

### **3.6 Usability**
- Provide a user-friendly Shiny interface with clear instructions and intuitive workflows.

---

## **4. System Requirements**

### **4.1 Hardware**
- Minimum Requirements:
  - CPU: Quad-core processor.
  - Memory: 16 GB RAM.
  - Storage: 100 GB free space for intermediate files and database.

### **4.2 Software**
- **Programming Language**: R (version 4.2 or later).
- **Database**: PostgreSQL 13+ for `vitaledge_datalake`.
- **R Packages**:
  - `VariantAnnotation`, `Biostrings`: For VCF parsing.
  - `httr`, `jsonlite`: For API queries.
  - `DBI`, `RPostgres`: For database interactions.
  - `shiny`: For building the web-based interface.
  - `testthat`: For unit testing.

---

## **5. Constraints**

1. **API Access**:
   - Annotation depends on external APIs (e.g., PharmGKB), which may have rate limits or require authentication.
2. **Data Privacy**:
   - Ensure compliance with HIPAA and GDPR for handling sensitive genomic data.
3. **Data Standardization**:
   - Follow established standards for storing genomic annotations (e.g., GA4GH).

---

## **6. Assumptions**

1. Input VCF files are pre-generated and follow standard formats.
2. External databases (e.g., PharmGKB, ClinVar) are accessible during annotation.
3. The **vitaledge_datalake** schema is extendable to accommodate pipeline-specific tables.

---

## **7. Success Criteria**

1. **Functional Pipeline**:
   - Successfully process a single-patient VCF file and generate pharmacogenomic annotations.
2. **Integration**:
   - Store annotated data in the `pharmacogenomic_annotations` table of the **vitaledge_datalake**.
3. **Usability**:
   - Enable users to upload VCF files, visualize data, and generate reports through the Shiny app.
4. **Reusability**:
   - Implement modular components that can be reused in other pipelines.

---

## **8. Future Considerations**

1. **Expanded Annotation Sources**:
   - Incorporate additional databases (e.g., dbSNP, COSMIC).
2. **High-Throughput Processing**:
   - Support parallel processing for large datasets.
3. **Advanced Visualization**:
   - Include more detailed filters, plots, and dashboards in the Shiny app.

---

## **9. Glossary**

- **VCF (Variant Call Format)**: A file format used to store information about genetic variants.
- **PharmGKB**: A pharmacogenomics knowledge resource.
- **ClinVar**: A database of clinically significant genetic variants.

---

## **10. References**

1. **PharmGKB API Documentation**: [https://www.pharmgkb.org/](https://www.pharmgkb.org/)  
2. **ClinVar Database**: [https://www.ncbi.nlm.nih.gov/clinvar/](https://www.ncbi.nlm.nih.gov/clinvar/)  
3. **Bioconductor VariantAnnotation Package**: [https://bioconductor.org/packages/release/bioc/html/VariantAnnotation.html](https://bioconductor.org/packages/release/bioc/html/VariantAnnotation.html)

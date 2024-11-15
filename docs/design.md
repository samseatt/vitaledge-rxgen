### **VitalEdge RxGen - Detailed Design Document**

This **Detailed Design Document** ensures that RxGen meets its functional, technical, and integration requirements while adhering to best practices for modular development.

#### **Project Name**:  
**VitalEdge RxGen**  

#### **Repository Name**:  
`vitaledge-rxgen`

---

## **1. Overview**

The **VitalEdge RxGen** module is a computational pipeline designed to process genomic Variant Call Format (VCF) files, annotate genetic variants with pharmacogenomic data, and store actionable insights in the **vitaledge_datalake**. This document provides a detailed design for the RxGen pipeline, focusing on modularity, reusability, and seamless integration with the broader **VitalEdge R Pipelines** ecosystem.

---

## **2. Architecture**

The architecture of RxGen is designed to ensure modularity, scalability, and interoperability with other VitalEdge modules. The pipeline consists of the following components:

### **2.1 High-Level Architecture**

```plaintext
+------------------+       +--------------------+       +-----------------------+
|   Input Layer    |  -->  | Processing Layer   |  -->  |   Output Layer        |
+------------------+       +--------------------+       +-----------------------+
       |                          |                               |
    VCF Files               Variant Parsing              Database (vitaledge_
       |                   + Pharmacogenomics            datalake) + Shiny
 External APIs             Annotation                   Interface
```

1. **Input Layer**:
   - Accepts VCF files.
   - Ensures validation and standardization of input data.
2. **Processing Layer**:
   - Parses variants using `VariantAnnotation`.
   - Annotates variants using external APIs (e.g., PharmGKB, ClinVar).
   - Normalizes data for storage.
3. **Output Layer**:
   - Saves annotated results to the PostgreSQL **vitaledge_datalake**.
   - Provides a Shiny interface for visualization and interaction.

---

### **2.2 Detailed Pipeline Workflow**

1. **VCF Input Validation**:
   - Validate the uploaded VCF file for standard compliance (e.g., metadata, format version).
   - Extract essential fields: sample ID, genomic coordinates, variant ID (e.g., rsID).

2. **Variant Parsing**:
   - Parse VCF files using `VariantAnnotation` to extract key details:
     - Chromosome, position, reference allele, alternate allele.
     - Variant type (e.g., SNP, indel).
     - Functional annotations if available.

3. **Pharmacogenomic Annotation**:
   - Query external databases (e.g., PharmGKB, ClinVar) for:
     - Gene-drug interactions.
     - Variant consequences (e.g., pathogenicity, benignity).
     - Drug response information (e.g., poor metabolizer, toxicity risk).
   - Combine annotations into a unified format.

4. **Data Transformation**:
   - Normalize variant annotations for storage:
     - Map extracted fields to database schema.
     - Standardize data types and formats.

5. **Data Storage**:
   - Insert processed results into the `pharmacogenomic_annotations` table in **vitaledge_datalake**.
   - Include metadata (e.g., processing timestamps, data sources).

6. **Visualization and Reporting**:
   - Provide interactive dashboards via Shiny for:
     - Uploading VCF files.
     - Querying annotated data.
     - Exporting reports (CSV, JSON).

---

## **3. Database Design**

### **3.1 Database Integration**
RxGen integrates with the **vitaledge_datalake**, a PostgreSQL-based central repository. The database schema ensures scalability and compatibility with future pipelines.

### **3.2 Schema for Pharmacogenomic Annotations**
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

- **`patient_id`**: Unique identifier for the patient (linked to broader patient data in the data lake).
- **`variant_id`**: Genomic variant identifier (e.g., rsID).
- **`gene_symbol`**: Gene affected by the variant.
- **`drug`**: Drug interacting with the gene/variant.
- **`interaction_type`**: Type of interaction (e.g., metabolizer, toxicity risk).
- **`clinical_significance`**: Clinical interpretation (e.g., pathogenic, benign).
- **`annotation_source`**: Source of the annotation (e.g., PharmGKB, ClinVar).
- **`created_at`**: Timestamp for provenance tracking.

---

## **4. Modular Design**

RxGen leverages reusable components from the shared `vitaledge-r-pipe` repository and builds pipeline-specific modules.

### **4.1 Shared Components**
- **Database Utilities (`db_utils.R`)**:
  - Functions for connecting to PostgreSQL.
  - Example:
    ```R
    connect_to_db <- function(config_file) {
      config <- yaml::read_yaml(config_file)
      DBI::dbConnect(RPostgres::Postgres(), dbname = config$dbname, ...)
    }
    ```

- **API Utilities (`api_utils.R`)**:
  - Functions for querying external APIs (e.g., PharmGKB).
  - Example:
    ```R
    query_pharmgkb <- function(variant_id) {
      response <- httr::GET("https://api.pharmgkb.org/v1/data/variant", query = list(variant = variant_id))
      jsonlite::fromJSON(httr::content(response, as = "text"))
    }
    ```

- **Logging and Error Handling (`logging.R`)**:
  - Centralized logging for error tracking and debugging.

---

### **4.2 Pipeline-Specific Modules**
- **Variant Parsing (`vcf_processing.R`)**:
  - Extracts variant data using `VariantAnnotation`.
- **Pharmacogenomic Annotation (`pharmgkb_annotation.R`)**:
  - Integrates variant data with external annotation sources.
- **Shiny Interface**:
  - Built using `shiny` with separate UI and server components.

---

## **5. Shiny App Design**

### **5.1 User Interface (UI)**
1. **File Upload**:
   - Allow users to upload VCF files.
2. **Annotation Results**:
   - Display annotated variants in a searchable table.
3. **Visualization**:
   - Include plots for:
     - Gene-variant interactions.
     - Drug categories.
4. **Export Options**:
   - Provide buttons to download results as CSV or JSON.

### **5.2 Server Logic**
1. Process the uploaded VCF file asynchronously.
2. Trigger variant parsing and annotation functions.
3. Store results in the database and cache for real-time queries.

---

## **6. API Integration**

### **6.1 PharmGKB API**
- **Endpoint**: `https://api.pharmgkb.org/v1/data/variant`
- **Query Parameters**:
  - `variant`: Variant identifier (e.g., rsID).

### **6.2 ClinVar API**
- **Endpoint**: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/`
- **Query Parameters**:
  - `db`: Database (e.g., ClinVar).
  - `term`: Search term (e.g., variant ID).

---

## **7. Testing and Validation**

### **7.1 Unit Testing**
- **Tools**: `testthat`
- **Examples**:
  - Test VCF parsing logic.
  - Validate API responses against known inputs.

### **7.2 Integration Testing**
- Test end-to-end functionality:
  - Upload VCF → Parse → Annotate → Store → Visualize.

---

## **8. Deployment**

### **8.1 Shiny App**
- **Hosting Options**:
  - RStudio Connect for enterprise hosting.
  - Shiny Server for self-hosted environments.

### **8.2 Pipeline Automation**
- Use `cron` or task schedulers to run the pipeline for batch processing.

---

## **9. Success Metrics**

1. **Performance**:
   - Process single-patient VCF files in <5 minutes.
2. **Accuracy**:
   - Annotate variants with >95% match accuracy from external sources.
3. **Usability**:
   - Intuitive Shiny app for VCF uploads and result exploration.

---

## **10. Conclusion**

The **VitalEdge RxGen** module is designed to deliver high-quality pharmacogenomic annotations, laying the foundation for future VitalEdge pipelines. Its modular, reusable design ensures scalability and seamless integration within the ecosystem.

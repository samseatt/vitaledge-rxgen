### **VitalEdge RxGen Design Document**

#### **1. Introduction**
The **RxGen module** of the VitalEdge system is a specialized R-based pipeline designed for **pharmacogenomic variant annotation**. It processes **VCF files** (containing genomic variant data), annotates them with drug-related information using a preloaded **pharmacogenomic_annotations catalog**, and stores the results in a **patient-specific table in the datalake**. 

With the integration of **DataBridge**, RxGen can now receive input VCF files programmatically through a unified handoff interface. This design aligns RxGen with the broader data ingestion workflow of VitalEdge while maintaining support for manual operation via its **Shiny UI** for small-scale or ad-hoc tasks.

---

#### **2. Objectives**
- **Seamless integration with DataBridge**: RxGen will receive input VCF files from DataBridge in a standardized manner.
- **Efficient processing**: Annotate only the variants present in the pharmacogenomic catalog, minimizing computational overhead.
- **Database integration**: Save the annotated results in the datalake's `patient_annotations` table.
- **Flexibility**: Allow both automated (via REST API) and manual (via Shiny UI) processing of files.
- **Extensibility**: Ensure the system is modular for future enhancements, such as additional annotation sources or extended reporting capabilities.

---

#### **3. High-Level Architecture**
RxGen is designed to operate as a microservice within the VitalEdge ecosystem. The key architectural components are:

1. **Input Handling**:
   - Receives VCF files from DataBridge through a REST API or processes files from a predefined folder.
   - Supports manual file upload through Shiny UI for ad-hoc annotations.

2. **Pharmacogenomic Annotation**:
   - Matches variants from the VCF file with entries in the `pharmacogenomic_annotations` catalog table in the datalake.
   - Discards variants not found in the catalog.

3. **Output Management**:
   - Saves results into the `patient_annotations` table with proper schema and referential integrity.

4. **Interfaces**:
   - **REST API**: For automated integration with DataBridge and external systems.
   - **Shiny UI**: For manual operation, status monitoring, and result visualization.

---

#### **4. Workflow**
The workflow for RxGen is as follows:

1. **Input**:
   - A VCF file is placed in the `queued` folder by DataBridge or manually.
   - The file location is communicated via REST API or selected through the Shiny UI.

2. **Processing**:
   - The VCF file is parsed using Bioconductor packages (e.g., `VariantAnnotation`).
   - The `rsID` values from the file are extracted and queried against the `pharmacogenomic_annotations` catalog.
   - Matching annotations are processed to generate a `patient_annotations` dataset.

3. **Output**:
   - The annotated results are inserted into the `patient_annotations` table in the datalake.
   - Logs are created for successful or failed processing.

4. **Feedback**:
   - REST API returns success/failure status and logs.
   - Shiny UI displays the results in a table and allows for CSV downloads.

---

#### **5. Integration with DataBridge**
RxGen integrates with DataBridge to streamline its input handling:

1. **Input Handoff**:
   - DataBridge places VCF files into a designated folder and sends a notification to RxGen's REST API (`/process`).

2. **REST API Workflow**:
   - RxGen reads the file location from the API request.
   - The file is processed and results are saved into the datalake.

3. **Error Handling**:
   - DataBridge is informed of any errors during processing via the API response.

---

#### **6. Database Schema**

**`pharmacogenomic_annotations` Table (Catalog Table)**
- Stores preloaded pharmacogenomic annotation data.
- Primary Key: `variant_id`.

**`patient_annotations` Table (Destination Table)**
- Stores patient-specific annotated results.
- Schema:
  ```sql
  CREATE TABLE patient_annotations (
      id SERIAL PRIMARY KEY,
      patient_id VARCHAR(255) NOT NULL,
      rs_id VARCHAR(255) NOT NULL,
      drug_id VARCHAR(255) NOT NULL,
      significance TEXT,
      notes TEXT,
      direction_of_effect TEXT,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW() ON UPDATE NOW(),
      UNIQUE (patient_id, rs_id, drug_id)
  );
  ```

---

#### **7. Interfaces**

1. **REST API**:
   - **Endpoint**: `/process`
     - **Method**: POST
     - **Payload**: `{ "patient_id": "12345", "vcf_file": "/path/to/file.vcf" }`
     - **Response**: `{ "status": "success", "message": "File processed successfully." }`
   - **Uses**: Automated input from DataBridge.

2. **Shiny UI**:
   - **Features**:
     - File upload for manual processing.
     - Folder processing for batch operations.
     - Results table and CSV export.

---

#### **8. Code Modules**

**`src/vcf_processing.R`**:
- Handles VCF file parsing and extraction of `rsID`.

**`src/db_queries.R`**:
- Contains functions for database connection, fetching catalog data, and saving patient annotations.

**`src/annotations.R`**:
- Combines VCF processing and annotation logic.

**`rest/app.R`**:
- Implements the REST API for integration with DataBridge.

**`shiny/ui.R` and `shiny/server.R`**:
- Provides the Shiny UI for manual operation.

---

#### **9. Deployment**

1. **Requirements**:
   - R version 4.4+.
   - PostgreSQL with the required tables created in the datalake.

2. **Environment Variables**:
   - Database credentials (`DB_NAME`, `DB_USER`, etc.).
   - Paths for input/output folders.

3. **Execution**:
   - Start REST API:
     ```bash
     Rscript rest/app.R
     ```
   - Launch Shiny App:
     ```bash
     Rscript shiny/app.R
     ```

---

#### **10. Future Enhancements**

1. **Support for Additional Annotation Sources**:
   - Integrate other pharmacogenomic datasets for richer annotations.

2. **Improved Error Reporting**:
   - Enhanced logging and notification for failures.

3. **Scalability**:
   - Add batch processing support for very large datasets using parallelization.

4. **Integration with Analytics**:
   - Provide annotated results for downstream analytics within VitalEdge.

---

### **Conclusion**
This refactored design aligns RxGen with the broader VitalEdge data ingestion system while maintaining flexibility for manual use. It ensures modularity, scalability, and extensibility for future enhancements.

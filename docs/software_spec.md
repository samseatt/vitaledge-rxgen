### **VitalEdge RxGen: Software Specification Document**

This specification defines a robust architecture and operational flow for VitalEdge RxGen, ensuring it integrates seamlessly into the VitalEdge ecosystem while meeting performance, scalability, and usability requirements.

---

#### **Introduction**
The VitalEdge RxGen pipeline is a bioinformatics R-based software designed to annotate patient genomic VCF files with pharmacogenomic insights. It forms part of the VitalEdge ecosystem, integrating tightly with the Data Bridge, Data Port, and Analytics microservices. This specification outlines the final, production-ready implementation of RxGen, focusing on functionality, API design, deployment architecture, and integration requirements.

---

### **System Overview**

#### **Purpose**
RxGen provides:
- Annotation of patient genomic variants with pharmacogenomic insights.
- Integration with a centralized annotations catalog or a local annotations file.
- Support for secure and reliable RESTful APIs for data scientists, clinicians, and administrators.
- Automation capabilities for efficient processing of new and updated data.

---

### **Features**

1. **Annotation Modes:**
   - **Database-Driven Annotation:** Matches VCF file variants against a database (`pharmacogenomic_annotations`) for annotation.
   - **File-Driven Annotation:** Matches VCF file variants against a local annotations catalog file (`pharmgkb_var_drug_ann.tsv`).

2. **Batch Processing:**
   - Processes VCF files in chunks to optimize memory and computational resource usage.

3. **Scheduling Integration:**
   - Integration with external scheduling systems (e.g., `cron`, custom schedulers, or Data Bridge).

4. **API Access:**
   - RESTful APIs for annotation requests, status checks, and catalog updates.
   - APIs for administrative tasks like querying annotation logs and triggering batch re-annotations.

5. **Security:**
   - JWT-based authentication for API endpoints.
   - Access control for database and annotations data.

6. **Logging and Monitoring:**
   - Comprehensive logging for audit trails.
   - Status reporting for ongoing and completed annotation tasks.

---

### **System Architecture**

#### **Deployment Architecture**
- **Bare-Metal Servers:**
  - Primary deployment on high-memory bare-metal servers.
  - Scalable to non-containerized Kubernetes clusters for high-throughput requirements.

#### **Integration Points**
1. **Input Sources:**
   - Patient VCF files from the Data Port (file system, S3 buckets, or similar).
   - Pharmacogenomic annotations from Data Loader (database or file-based).

2. **Output Destinations:**
   - Datalake tables for `patient_annotations` and related outputs.

3. **Schedulers:**
   - External schedulers (e.g., `cron`) for automated requests.
   - Flask-based UI for manual initiation and monitoring.

---

### **RESTful API Specification**

#### **1. Annotation APIs**
##### **1.1. Start Annotation**
**Endpoint:** `POST /annotate`  
**Description:** Triggers the annotation process for a patient’s VCF file.  
**Parameters:**  
- `file_path` (string): Path to the VCF file.
- `patient_id` (string): Unique identifier for the patient.
- `mode` (string, optional): Annotation mode, either `"database"` (default) or `"file"`.
- `catalog_file` (string, optional): Path to annotations catalog file (required for `"file"` mode).

**Response:**
- `status` (string): `success` or `error`.
- `message` (string): Details of the result or error.

##### **1.2. Check Annotation Status**
**Endpoint:** `GET /status`  
**Description:** Retrieves the status of a specific annotation job.  
**Parameters:**  
- `job_id` (string): Unique identifier for the annotation job.

**Response:**
- `status` (string): Current status (`queued`, `running`, `completed`, `failed`).
- `progress` (integer): Percentage of completion.
- `message` (string): Additional details.

---

#### **2. Catalog APIs**
##### **2.1. Update Annotations Catalog**
**Endpoint:** `POST /catalog/update`  
**Description:** Updates the pharmacogenomic annotations catalog.  
**Parameters:**  
- `file_path` (string): Path to the updated annotations catalog file.

**Response:**
- `status` (string): `success` or `error`.
- `message` (string): Details of the result or error.

##### **2.2. Query Catalog**
**Endpoint:** `GET /catalog/query`  
**Description:** Searches the annotations catalog for a specific variant or drug.  
**Parameters:**  
- `variant_id` (string, optional): Variant ID (e.g., `rs5031016`).
- `drug_name` (string, optional): Drug name to search.

**Response:**
- `results` (array): Matching catalog entries.

---

#### **3. Administrative APIs**
##### **3.1. Re-Annotation**
**Endpoint:** `POST /reannotate`  
**Description:** Triggers re-annotation of all existing patients based on updated catalog data.  
**Parameters:**  
- `catalog_version` (string): Version of the catalog to use for re-annotation.

**Response:**
- `status` (string): `success` or `error`.
- `message` (string): Details of the result or error.

---

### **Database Design**

#### **Pharmacogenomic Annotations Table**
- **Purpose:** Stores catalog data for database-driven annotations.
- **Columns:**
  - `id` (integer): Primary key.
  - `variant_id` (string): Variant identifier (e.g., `rs5031016`).
  - `drug_id` (integer): Foreign key to the `drugs` table.
  - `phenotype_category`, `significance`, `notes` (text): Annotation details.

#### **Patient Annotations Table**
- **Purpose:** Stores annotation results for each patient.
- **Columns:**
  - `id` (integer): Primary key.
  - `patient_id` (string): Unique identifier for the patient.
  - `variant_id`, `annotation_id`, `drug_id` (references): Related data.
  - `timestamp` (datetime): Time of annotation.

---

### **Processing Workflow**

1. **Input Validation:**
   - Verify file existence, patient ID, and mode.
   - Ensure catalog file is provided if using `"file"` mode.

2. **Batch Processing:**
   - Chunk the VCF file into manageable portions.
   - Query the database or parse the catalog file in chunks.

3. **Annotation Matching:**
   - Compare variants to the annotations catalog.
   - Store matching results in the `patient_annotations` table.

4. **Completion Logging:**
   - Log the completion status and results for auditing.

---

### **Deployment Guidelines**

#### **Local Development**
- Use RStudio or terminal to run the pipeline (`Rscript api/api.R`).
- Configure ports and database connections in `config/api_config.yml`.

#### **Production Deployment**
1. **Bare-Metal Servers:**
   - Install required R packages using `renv::restore()`.
   - Use `systemd` or similar service management for running APIs.

2. **Scheduling:**
   - Use `cron` or similar for scheduled requests to the API.

3. **High-Throughput Clusters:**
   - Use Kubernetes with the pipeline directly managed as a bare-metal service (non-containerized).

---

### **Security Considerations**
1. **Authentication:**
   - JWT-based token validation for all endpoints.
   - Integration with VitalEdge Security microservice.

2. **Data Privacy:**
   - Encrypt sensitive data in transit.
   - Use de-identified patient IDs in analysis pipelines.

---

### **Future Enhancements**
- Support for additional genomic file formats (e.g., BAM, FASTQ).
- Integration with external APIs for real-time drug interaction checks.
- Enhanced analytics dashboards via Flask UI.

---

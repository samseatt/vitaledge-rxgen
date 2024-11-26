# VitalEdge RxGen

**VitalEdge RxGen** is an R-based bioinformatics pipeline designed to annotate patient genomic VCF files with pharmacogenomic insights. It is a key component of the VitalEdge ecosystem, contributing to personalized medicine by integrating genomic data into actionable clinical insights.

---

## **Key Features**

- **Annotation Modes**:
  - Database-driven annotations from a `pharmacogenomic_annotations` table.
  - File-driven annotations using `pharmgkb_var_drug_ann.tsv`.

- **Batch Processing**:
  - Efficiently handles large VCF files through chunked processing.

- **RESTful API**:
  - Provides endpoints for triggering annotations, checking job statuses, and querying/updating catalogs.

- **Scalability**:
  - Designed for deployment on bare-metal servers or Kubernetes clusters.

- **Security**:
  - JWT-based authentication for secure API access.
  - Integration with VitalEdge Security microservice.

---

## **Repository Structure**

```
vitaledge-rxgen/
├── api/                     # RESTful API handlers and configuration
│   ├── endpoints/           # API endpoint implementations
│   ├── api.R                # Main entry point for Plumber API
├── config/                  # Configuration files for API and database
│   ├── api_config.yml       # API configuration
│   ├── db_config.yml        # Database configuration
├── data/                    # Example data files for testing
│   ├── example.vcf          # Sample VCF file
│   ├── pharmgkb_var_drug_ann.tsv  # Example annotations catalog
├── docs/                    # Documentation and guides
│   ├── usage.md             # Guide on using RxGen
│   ├── architecture.md      # Architectural overview
├── src/                     # Core processing scripts
│   ├── process_vcf.R        # Main VCF processing logic
│   ├── utils.R              # Utility functions
│   ├── catalog_processing.R # Catalog-specific logic
├── tests/                   # Test scripts for API and processing
│   ├── test_process_vcf.R   # Unit tests for VCF processing
│   ├── test_endpoints.R     # Unit tests for API endpoints
├── .env.example             # Example environment variables file
├── README.md                # Repository overview (this file)
├── renv.lock                # R package lockfile for reproducibility
├── renv/                    # R environment management directory
└── LICENSE                  # Project license
```

---

## **Installation**

### **Prerequisites**
- **R**: Version 4.4.2 or higher.
- **R Packages**: Use `renv` to install all required packages:
  ```bash
  R -e "install.packages('renv'); renv::restore()"
  ```
- **PostgreSQL**: Required for database-driven annotations.

### **Setup**
1. Clone the repository:
   ```bash
   git clone https://github.com/vitaledge/vitaledge-rxgen.git
   cd vitaledge-rxgen
   ```

2. Configure environment variables:
   - Copy `.env.example` to `.env` and update with your settings.

3. Set up the database:
   - Ensure PostgreSQL is running and configure `config/db_config.yml`.

4. Start the API:
   ```bash
   Rscript api/api.R
   ```

---

## **Usage**

### **API Endpoints**

#### **1. Start Annotation**
**Endpoint:** `POST /annotate`  
**Description:** Triggers the annotation process for a patient’s VCF file.  
**Example cURL Command:**
```bash
curl -X POST http://localhost:8000/annotate \
  -H "Content-Type: application/json" \
  -d '{
    "file_path": "/path/to/vcf/file.vcf",
    "patient_id": "12345",
    "mode": "database"
  }'
```

#### **2. Check Annotation Status**
**Endpoint:** `GET /status`  
**Description:** Retrieves the status of an annotation job.  
**Example cURL Command:**
```bash
curl -X GET "http://localhost:8000/status?job_id=job123"
```

#### **3. Query Catalog**
**Endpoint:** `GET /catalog/query`  
**Description:** Searches the pharmacogenomic annotations catalog.  
**Example cURL Command:**
```bash
curl -X GET "http://localhost:8000/catalog/query?variant_id=rs5031016"
```

---

## **Development**

### **Local Development**
1. Run the API locally using `Rscript`:
   ```bash
   Rscript api/api.R
   ```

2. Use testing tools such as `postman` or `curl` to test endpoints.

### **Testing**
- Run unit tests for core functionality:
  ```bash
  Rscript tests/test_process_vcf.R
  ```

---

## **Deployment**

### **Bare-Metal Deployment**
1. Install necessary R packages using `renv`.
2. Configure `systemd` or a similar service manager to run `api.R` at startup.
3. Use a scheduler (e.g., `cron`) to trigger annotation jobs automatically.

### **Kubernetes Deployment**
- Deploy RxGen as a non-containerized service within a Kubernetes cluster.
- Use Kubernetes CronJobs for scheduling annotation tasks.

---

## **Contributing**

1. Fork the repository.
2. Create a new branch for your feature:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add feature"
   ```
4. Push and create a pull request.

---

## **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## **Acknowledgments**

- The RxGen pipeline leverages the **Bioconductor** project for high-performance bioinformatics operations.
- Inspired by the larger **VitalEdge ecosystem**.

--- 

For more details, refer to the [Documentation](docs/).

# Base Image
FROM rocker/r-ver:4.4.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libpq-dev \
  zlib1g-dev \
  libbz2-dev \
  liblzma-dev \
  libncurses5-dev \
  wget \
  bzip2 \
  libsodium-dev \
  && apt-get clean

# Install HTSlib from source
RUN wget https://github.com/samtools/htslib/releases/download/1.17/htslib-1.17.tar.bz2 \
    && tar -xjf htslib-1.17.tar.bz2 \
    && cd htslib-1.17 \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf htslib-1.17 htslib-1.17.tar.bz2

# Install R dependencies
RUN R -e "install.packages('renv')"

# Set the working directory
WORKDIR /app

# Copy application code
COPY . /app

# Restore R packages
RUN R -e "renv::restore()"

# Expose API port
EXPOSE 8000

# Run the API
CMD ["Rscript", "api.R"]

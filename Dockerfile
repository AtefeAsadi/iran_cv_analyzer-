# ============================================
# Stage 1: Base — Official Shiny Image
# ============================================
FROM rocker/shiny:4.3.0 AS base

# Install system dependencies required for R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    pkg-config \
    libgit2-dev \
    libpoppler-cpp-dev \
    libsass-dev \
    && rm -rf /var/lib/apt/lists/*

# Install additional R packages (shiny is already installed)
RUN R -e "install.packages(c('bslib', 'pdftools', 'stringr', 'httr', 'jsonlite'), repos='https://cran.rstudio.com/')"

WORKDIR /app
COPY . .

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('IRAN_CV.R', host='0.0.0.0', port=3838)"]

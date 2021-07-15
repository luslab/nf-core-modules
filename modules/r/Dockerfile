# Set the base image to Ubuntu 16.04
FROM rocker/r-base:4.1.0

LABEL authors="alex.thiery@crick.ac.uk" \
    description="Docker image containing Rstudio and getopt"

# Install R packages
RUN R -e "install.packages('getopt')"

# Set the base image to Ubuntu 16.04
FROM ubuntu:16.04

LABEL authors="alex.thiery@crick.ac.uk" \
      description="Docker image containing cellranger"

# update apt-get and install
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

# Install cellranger
RUN cd /opt/ && \
	wget -O cellranger-6.0.0.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-6.0.0.tar.gz?Expires=1618022770&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci02LjAuMC50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2MTgwMjI3NzB9fX1dfQ__&Signature=Hd~iecpvicUE2quegKM137tAG3ImFJ~PGWwCDu93MzooOMDcPa5umJBVHdOrM6qKp7ePNmvkSg-NEGDX8sYovd9G3U6n3bpLEomHLI7~J79Lq6J9UhMTFB~vbQO6CLqLao~Ju7dnf3AGWjdULrVO1ZN~tZqPVG5DVZG31D0~P6y5BNT2Q2uEygsCbCJABQCLJJFDSO3P-kzJR1M1mVxOwg3WbFalNOqq~uJ2ZAbKtcdPR7CckEJknIZGYmmUnW3E0-kU00IE-yGEk7OMMNOdLW7SI4s~JGp5~KkvizPL6N9YajUkDgiQPCAVuJkVfW2b0W2cKuImYj9H2s~qKZShPg__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" && \
  tar -xzvf cellranger-6.0.0.tar.gz && \
	rm -f cellranger-6.0.0.tar.gz

# Set path
ENV PATH /opt/cellranger-6.0.0:$PATH
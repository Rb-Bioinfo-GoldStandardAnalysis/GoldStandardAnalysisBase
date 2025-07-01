# Example of Docker image 

# You have to build the image starting from another already existing one. 
# Here we have used "rocker/r-ver" version 4.4.1:
# - This image has already both Ubuntu (the operating system) and R, you can specify the version to use by writing image_name:version
# - Another image that already has both ubuntu and R is r-base, but rocker/r-ver is preferred because it is build to be more stable and reliable (https://github.com/rocker-org/rocker-versioned2)
# --platform=linux/amd64 maes so it si compatible with both arm and x86 based system
FROM --platform=linux/amd64 rocker/r-ver:4.4.1

# These are various things that are installed for ubuntu, they are here to make sure that thing work, they limit/prevent errors
# Knowing what most of them are is not important, just put them in your docker file
# Some notable are:
# - sudo: gives root acces 
# - curl & wget: needed to download scripts from the internet
RUN apt update && apt install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    gpg \
    curl \ 
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    make \
    cmake \
    gfortran \
    libxt-dev \
    liblapack-dev \
    libblas-dev \
    sudo \
    wget \
    libzmq3-dev \
    libglpk40 \
    libglpk-dev

# Install system and Python packages. Then istall JupyterLab environment
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv nano curl && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip jupyterlab

# EModifies the path to inclute the virtual environment in which we installed JupyterLab
ENV PATH="/opt/venv/bin:$PATH"

# IRkernel (Interactive R kernel) allows JupyterLab to use R 
RUN R -e "install.packages(\"IRkernel\")" \
    R -e "IRkernel::installspec(user = FALSE)"

# Download R libraries 
RUN R -e "install.packages( \
    c(\"BiocManager\", \
    \"devtools\", \
    \"dplyr\", \
    \"ggplot2\", \
    \"tibble\", \
    \"gridExtra\", \
    \"data.table\", \
    \"future\", \
    \"cowplot\", \
    \"remotes\" \
    ))" 
RUN R -e "BiocManager::install(\"tidyverse\")"

# Seurat v.4.3.0
# SeuratObjec installed 2 times due to unwanted automatic update
RUN R -e "remotes::install_version(\"SeuratObject\", version = \"4.1.4\")" \
    R -e "remotes::install_version(\"Seurat\", version = \"4.3.0\")" \
    R -e "remotes::install_version(\"SeuratObject\", version = \"4.1.4\")" \
    R -e "devtools::install_github('immunogenomics/presto')"

# Download the R script from GitHub
RUN mkdir -p /Scripts && \
    cd /Scripts && \
    curl -O https://raw.githubusercontent.com/Maiolino-Au/GoldStandardAnalysis/main/pashos_h3k36/Scripts/0_Download.R
# or if you have donwloaded the git repository you can copy the script directly
#COPY ./pashos_h3k36/Scripts/. /Scripts/

# Make /bin/bash the default shell
ENV SHELL=/bin/bash

# All the other commands in a dockerfile represent a layer of the image, 
# this last one is not a layer but a command that is executed upon startup of a container originating from this image.
# Here we launch JupyterLab, map the container to port 8888, disable the requirement of a token/password for the container
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.allow_origin='*' --ServerApp.token='' #last one disables the token

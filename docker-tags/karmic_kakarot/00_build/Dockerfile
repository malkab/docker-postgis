# --------------------------------------
#
# Build
#
# --------------------------------------
FROM debian_gp:bookworm

LABEL author="Juan Pedro Perez"
LABEL email="jp.perez.alcantara@gmail.com"

# User root
USER root

# Environment
ARG DOCKER_IMAGE_TAG
ENV DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG}
ARG GDAL_VERSION
ENV GDAL_VERSION=${GDAL_VERSION}
ARG GEOS_VERSION
ENV GEOS_VERSION=${GEOS_VERSION}
ARG POSTGIS_VERSION
ENV POSTGIS_VERSION=${POSTGIS_VERSION}
ARG PG_VERSION
ENV PG_VERSION=${PG_VERSION}
ARG PROJ_VERSION
ENV PROJ_VERSION=${PROJ_VERSION}

ADD packages/gdal-${GDAL_VERSION}.tar.gz /usr/local/src/
ADD packages/geos-${GEOS_VERSION}.tar.bz2 /usr/local/src/
ADD packages/postgis-${POSTGIS_VERSION}.tar.gz /usr/local/src/
ADD packages/postgresql-${PG_VERSION}.tar.bz2 /usr/local/src/
ADD packages/proj-${PROJ_VERSION}.tar.gz /usr/local/src/
ADD packages/fzf-0.54.3-linux_amd64 /usr/local/bin/fzf

ADD build_scripts /build_scripts_postgis

# # Install basic dependencies
RUN apt-get update && \
        apt-file update && \
        updatedb && \
        tee /apt_get_basic_dependencies.log

# Compile
WORKDIR /build_scripts_postgis

# A partir de aquí se puede se pueden comentar las líneas que no
# se quieren ejecutar para con make run entrar interactivamente a
# ella y depurar problemas.
RUN ./010-install_dependencies.sh | tee 010-install_dependencies.log
RUN ./020-build_postgresql.sh | tee 020-build_postgresql.log
RUN ./030-build_geos.sh | tee 030-build_geos.log
RUN ./040-build_proj.sh | tee 040-build_proj.log
RUN ./050-build_gdal.sh | tee 050-build_gdal.log
RUN ./060-build_postgis.sh | tee 060-build_postgis.log

# User debian
USER debian

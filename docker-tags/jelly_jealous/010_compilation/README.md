# Compilation of PostgreSQL 15.3, PostGIS 3.3.4, GDAL 3.7.1

This image is not intended for production, nor to upload it to any registry. It's an image to compile from source a PostGIS, take the binaries and build with them a production-ready Docker image (check **020_production** image). It uses a non-volatile container where the building process (which may change between versions) can be tested and time-consuming building steps be made persistable.

This image also serves as the base image for the **docker-grass** series of images that installs GRASS and a big deal of other software to create a super geodata scientist processing image. Image tags of **docker-grass** mimics the one on this repo.

**WARNING:** this build seems not to be able to reproject from ED50 to ETRS89 using the spanish transformation grids for all transformations. Check if PostGIS is able to perform the transformation correctly for a given datum shift. The most common transformations are taken into account.


## Versions

This Dockerfile compiles from source the following software:

- PostgreSQL 15.3;

- GEOS 3.12.0;

- Proj 9.2.1;

- GDAL 3.7.1;

- PostGIS 3.3.4.

Also check the version of the **Docker Ubuntu base image** in the **Dockerfile** at **Docker Hub** and update it to the latest LTS.


## Building

Put the downloaded source code tars in their folders at **010_compilation/packages**. It's very important to take note of the tested versions for each package in the section above.

Please note that **PostgreSQL** version scheme has two version numbers, while the rest has three.

Then, update **mlkctxt** with the versions and the new image tag and activate the **default** context.

Then follow the scripts. This will create an image that installs all the assets needed for testing and validating the build process is a persistent way:

- [] modify the **mlkctxt.yaml** with versions and ssh credentials if going to build on remote;

- [] activate the **default** context. Review the produced BASH scripts because sometimes minor versions are sometimes missed;

- [] at the **Dockerfile.mlkctxt_template**, check if there is a more recent Ubuntu LTS base image to work with and update (https://wiki.ubuntu.com/Releases, https://hub.docker.com/_/ubuntu);

- [] **rsync** to remote and **ssh**, if applicable;

- [] run **010** to create an image called **malkab/postgis_compilation:XXX** with all the assets to test and produce the compilation of the stack;

- [] create a non-volatile container to test the compilation with **020** that will be named **postgis_compilation_XXX**. This container is very important because it will store the result of compilation processes that are very time consuming and that will be used to extract the binaries for production. Exit and reenter to it with **030**;

- [] once inside the container compilation work can start. Execution of scripts at **build_scripts** can be used to try a unassissted compilation of the full stack, or try it step by step. Don't drop the compilation container to keep already successfull steps;

- [] run inside the container **tests/cs2cs.sh** to check datum shiftings;

- [] extract binaries inside the container with **build_scripts/900**. This will place in **exported_binaries** folder containing all that the production image needs;

- [] fix the compilation process at the container in an image. Exit the container and run **050**. A new image called **malkab/postgis_compilation_final:xxx** will be created. This is useful to further process other images like the GRASS one. **DON'T** drop this compilation image;

- [] proceed to **020_production**.


## A note on Datum Shifting

The PROJ version installed comes with the Spanish National Grids for datum shifting between ED50 and ETRS89. However, it has been tested to work only in these transformations:

- **ED50 UTM30N (EPSG:23030) to ETRS89 UTM30N (EPSG:25830)**;

- **ED50 UTM31N (EPSG:23031) to ETRS89 UTM31N (EPSG:25831)**.

Other transformations won't work with the current grid.

To test datum shifting, use the following coordinate transformations, performed by the IGN's geodesic calculator:

- **EPSG:23028 to EPSG:25828:** 235200 4142110  >  235076.64 4141872.38

- **EPSG:23029 to EPSG:25829:** 235200 4142110  >  235086.89 4141884.24

- **EPSG:23030 to EPSG:25830:** 235200 4142110  >  235088.76 4141905.91

- **EPSG:23031 to EPSG:25831:** 235200 4142110  >  235103.57 4141908.03

- **EPSG:4230 to EPSG:4258:**   5 37            >  5.00131943 36.99873538

Use the **tests/cs2cs.sh** script to test different transformations.

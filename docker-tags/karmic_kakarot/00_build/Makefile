# ¡ATENCIÓN! Esto hay que cambiarlo también en el FROM del Dockerfile.
# Nombre de la imagen base, nombre:tag.
BASE_IMAGE_NAME=debian_gp:bookworm
# Nombre de la imagen, nombre:tag.
IMAGE_NAME=postgis_build:karmic_kakarot
IMAGE_SAVE_NAME=postgis_build_karmic_kakarot

# Versiones
GDAL_VERSION=3.9.2
GEOS_VERSION=3.12.2
POSTGIS_VERSION=3.4.2
PG_VERSION=16.4
PROJ_VERSION=9.1.1

# Para el push a registros privados, especialmente el Gitea.
PUSH_OWNER=whateveruser
PUSH_REGISTRY=a.gitea.com
PUSH_REGISTRY_URL=https://$(PUSH_REGISTRY)

# Atajos.
GIT_COMMIT=$(shell git rev-parse --short=6 HEAD)

LAST_SAVED_VERSION=$(shell \
	find . -maxdepth 1 -type f \
		-name '$(IMAGE_SAVE_NAME)_*.tar.gz' \
		-printf '%T@ %p\n' | \
	sort -nr | \
	head -n1 | \
	cut -d' ' -f2-)

# Ejecuta la imagen base para depurar.
base_image_run:
	@docker run -ti --rm \
		-v $(shell pwd):$(shell pwd) \
		--workdir $(shell pwd) \
		--entrypoint /bin/bash \
		$(BASE_IMAGE_NAME)

# Build.
build:
	@docker build --force-rm \
		-t $(IMAGE_NAME) \
		--build-arg DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG) \
    	--build-arg GDAL_VERSION=$(GDAL_VERSION) \
    	--build-arg GEOS_VERSION=$(GEOS_VERSION) \
    	--build-arg POSTGIS_VERSION=$(POSTGIS_VERSION) \
    	--build-arg PG_VERSION=$(PG_VERSION) \
    	--build-arg PROJ_VERSION=$(PROJ_VERSION) \
		.

# Ejecuta la imagen construída. Genera un contenedor no temporal
# para poder experimentar con las compilaciones, que pueden ser
# largas.
create_run_build_container:
	@docker run -ti \
		--name $(IMAGE_SAVE_NAME)_build \
		-v $(shell pwd):$(shell pwd) \
		$(IMAGE_NAME)

drop_build_container:
	-@docker rm -f $(IMAGE_SAVE_NAME)_build

# Subida.
push:
	-@echo "Subiendo imagen $(IMAGE_NAME) a $(PUSH_REGISTRY_URL), no olvidar hacer primero login"

	-@docker tag \
		$(IMAGE_NAME) \
		$(PUSH_REGISTRY)/$(PUSH_OWNER)/$(IMAGE_NAME)

	-@docker push \
		$(PUSH_REGISTRY)/$(PUSH_OWNER)/$(IMAGE_NAME)

# Respaldo a tar.gz de la imagen.
save:
	@docker image save $(IMAGE_NAME) $(IMAGE_NAME) | gzip > \
		$(IMAGE_SAVE_NAME)_$(GIT_COMMIT).tar.gz

# Eliminar activos.
clean:
	-@docker image rm $(IMAGE_NAME)

	-@docker image rm $(PUSH_REGISTRY)/$(PUSH_OWNER)/$(IMAGE_NAME)

# Refresca la imagen con el hash actual del GIT
ifneq ($(strip $(LAST_SAVED_VERSION)),)
update_save:
	-@mv $(LAST_SAVED_VERSION) \
		$(IMAGE_SAVE_NAME)_$(GIT_COMMIT).tar.gz
endif

NAME   := krav/borderland-account
TAG    := $$(git log -1 --pretty='%H')
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest
STABLE := ${NAME}:stable

build:
	docker build -t ${IMG} .
	docker tag ${IMG} ${LATEST}

stable:
	docker tag ${IMG} ${STABLE}
	docker push ${NAME}

push:
	docker push ${NAME}

develop:
	echo See Dockerfile on how to disable caching
	docker run -p 8080:8080 -v $(shell pwd)/themes/borderland:/opt/jboss/keycloak/themes/borderland  -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin ${LATEST}


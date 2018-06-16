VENV=./ve
PYTHON=$(VENV)/bin/python
PIP=$(VENV)/bin/pip
PROJECT=swagger_aor_generator
GENERATE_DIR="./shared/generated"

DOCKER_EXEC=$(shell which docker)

$(VENV):
	@virtualenv $(VENV) --python=python3.6

virtualenv: $(VENV)
	@$(PIP) install -r requirements.txt

clean-virtualenv:
	@rm -rf $(VENV)

test:
	@$(VENV)/bin/nosetests --verbose

demo-all: demo-aor permissions-demo-aor demo-ra

AOR_DIR = "$(GENERATE_DIR)/demo/aor"
demo-aor:
	@mkdir -p $(AOR_DIR)
	@$(PYTHON) src/generator.py tests/resources/petstore-aor.json aor --output-dir=$(AOR_DIR) --module-name="A Pet Admin" --rest-server-url="localhost:3000/api/v1"

AOR_PERMS_DIR = "$(GENERATE_DIR)/demo/aor-permissions"
permissions-demo-aor:
	@mkdir -p $(AOR_PERMS_DIR)
	@$(PYTHON) src/generator.py tests/resources/petstore-aor.json aor --output-dir=$(AOR_PERMS_DIR) --module-name="A Pet Admin" --rest-server-url="localhost:3000/api/v1" --permissions

RA_DIR = "$(GENERATE_DIR)/demo/react-admin"
demo-ra:
	@mkdir -p $(RA_DIR)
	@$(PYTHON) src/generator.py tests/resources/petstore-aor.json ra --output-dir=$(RA_DIR) --module-name="A Pet Admin" --rest-server-url="localhost:3000/api/v1"

clean-demo:
	@rm -rf -p $(GENERATE_DIR)/demo

docker: docker-build docker-run-demo-ra

docker-build:
	@$(DOCKER_EXEC) build -t swagger-aor-generator:python3.6-alpine .

docker-run:
	@$(DOCKER_EXEC) run --rm -ti -p 3000:3000 -v `pwd`/shared:/shared swagger-aor-generator:python3.6-alpine 

docker-run-demo-aor:
	@$(DOCKER_EXEC) run --rm -it -p 3000:3000 -v `pwd`/shared:/shared swagger-aor-generator:python3.6-alpine demo-aor

docker-run-demo-aor-permissions:
	@$(DOCKER_EXEC) run --rm -it -p 3000:3000 -v `pwd`/shared:/shared swagger-aor-generator:python3.6-alpine demo-aor-permissions

docker-run-demo-ra:
	@$(DOCKER_EXEC) run --rm -it -p 3000:3000 -v `pwd`/shared:/shared swagger-aor-generator:python3.6-alpine demo-ra

docker-run-bash:
	@$(DOCKER_EXEC) run --rm -ti -p 3000:3000 -v `pwd`/shared:/shared swagger-aor-generator:python3.6-alpine bash

docker-run-virtualenv:
	@$(DOCKER_EXEC) run --rm -ti -p 3000:3000 -v `pwd`/shared:/shared swagger-aor-generator:python3.6-alpine virtualenv

docker-run-dev:
	@$(DOCKER_EXEC) run --rm -ti -p 3000:3000 -v `pwd`/shared:/shared swagger-aor-generator:python3.6-alpine dev




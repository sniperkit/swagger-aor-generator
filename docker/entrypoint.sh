#!/bin/sh

set -x
set -e

export ADMIN_MODULE_NAME="${ADMIN_MODULE_NAME:-"A Pet Admin"}"
export ADMIN_REST_SERVER_URL="${ADMIN_REST_SERVER_URL:-"localhost:3000/api/v1"}"
export ADMIN_VERSION="${ADMIN_VERSION:-"aor"}"

export SHARED_DIR=${SHARED_DIR:-"/shared"}
export OUTPUT_DIR=${OUTPUT_DIR:-"${SHARED_DIR}/generated"}

export RESOURCES_DIR=${RESOURCES_DIR:-"${SHARED_DIR}/resources"}
# examples: m2m-cms-swagger.json, eventcity-swagger.json, product-master-swagger.json
export RESOURCES_FILENAME=${RESOURCES_FILENAME:-"m2m-cms-swagger.json"}
export RESOURCES_FILEPATH=${RESOURCES_FILEPATH:-"${RESOURCES_DIR}/${RESOURCES_FILENAME}"}

export PYTHON_VERSION="${PYTHON_VERSION:-"3.6"}"
export PYTHON_EXEC=$(which python)

export PYTHON_PIP=$(which pip)
export PYTHON_PIP_REQ_FILEPATH=${PYTHON_PIP_REQ_FILEPATH:-"/requirements.txt"}
export PYTHON_PIP_ARGS=${PYTHON_PIP_ARGS:-"install -r ${PYTHON_PIP_REQ_FILEPATH}"}
export PYTHON_PIP_CMD=${PYTHON_PIP_CMD:-"${PYTHON_PIP} ${PYTHON_PIP_ARGS}"}

export PYTHON_VENV="${PYTHON_VENV:-"./ve"}"
export PYTHON_VIRTUALVENV=$(which virtualenv)
export PYTHON_VIRTUALVENV_ARGS="${PYTHON_VIRTUALVENV_ARGS:-"--python=python${PYTHON_VERSION}"}"
export PYTHON_VIRTUALVENV_CMD="${PYTHON_VIRTUALVENV_CMD:-"${PYTHON_VIRTUALVENV} ${PYTHON_VIRTUALVENV_ARGS}"}"

export CURRENT_DIR=$(pwd)
export ENTRY=$1

function ensure() {
	local output_dir=${1:="/shared/generated/latest"}
	mkdir -p ${output_dir}
}

case "$1" in

  'bash')
	apk add --no-cache --no-progress bash nano jq findutils
	export JQ_EXEC=$(which jq)
	export BASH_EXEC=$(which bash)
	export NANO_EXEC=$(which nano)
	ls -l /shared
  	exec /bin/bash $@
	;;

  'virtualenv')
   	apk add --no-cache --no-progress bash nano ca-certificates git libssh2 openssl findutils
   	exec ${PYTHON_PIP} install --no-cache-dir virtualenv
    exec ${PYTHON_VIRTUALVENV_CMD}
    exec ${PYTHON_PIP_CMD}
	ls -l /shared
    exec /bin/bash $@
  ;;

  'dev')
	APK_DEV=${APK_DEV:-"findutils bash nano jq gcc musl-dev make cmake openssl-dev libssh2-dev build-base cmake g++ linux-headers openssl python3-dev ca-certificates wget vim"}
	apk add --no-cache --no-progress ${APK_DEV}
	export JQ_EXEC=$(which jq)
	export BASH_EXEC=$(which bash)
	export NANO_EXEC=$(which nano)
	export CMAKE_EXEC=$(which cmake)
	export MAKE_EXEC=$(which make)
	ls -l /shared
  	exec /bin/bash $@
	;;

  'demo')
	export ADMIN_VERSION="$@"
	export OUTPUT_DIR="${GENERATE_DIR}/demo/$@"
	ensure ${OUTPUT_DIR}
	pwd
	ls -la
	ls -l /shared
	exec python3 generator.py ${RESOURCES_FILEPATH} ${ADMIN_VERSION} --output-dir=${OUTPUT_DIR} --module-name="${ADMIN_MODULE_NAME}" --rest-server-url="${ADMIN_REST_SERVER_URL}"
	;;

  'demo-aor')
	export ADMIN_VERSION="aor"
	export OUTPUT_DIR="${GENERATE_DIR}/demo/aor"
	ensure ${OUTPUT_DIR}
	pwd
	ls -la
	ls -l /shared
	exec python3 generator.py ${RESOURCES_FILEPATH} ${ADMIN_VERSION} --output-dir=${OUTPUT_DIR} --module-name="${ADMIN_MODULE_NAME}" --rest-server-url="${ADMIN_REST_SERVER_URL}"
	;;

  'demo-aor-permissions')
	export ADMIN_VERSION="aor"
	export OUTPUT_DIR="${GENERATE_DIR}/demo/aor-perms"
	ensure ${OUTPUT_DIR}
	pwd
	ls -la
	ls -l /shared
	exec python3 generator.py ${RESOURCES_FILEPATH} ${ADMIN_VERSION} --output-dir=${OUTPUT_DIR} --module-name="${ADMIN_MODULE_NAME}" --rest-server-url="${ADMIN_REST_SERVER_URL}" --permissions
	;;

  'demo-ra')
	export ADMIN_VERSION="ra"
	export OUTPUT_DIR="${GENERATE_DIR}/demo/react-admin"
	ensure ${OUTPUT_DIR}
	pwd
	ls -la
	ls -l /shared
	exec python3 generator.py ${RESOURCES_FILEPATH} ${ADMIN_VERSION} --output-dir=${OUTPUT_DIR} --module-name="${ADMIN_MODULE_NAME}" --rest-server-url="${ADMIN_REST_SERVER_URL}"
	;;

  *)
  	exec /bin/sh $@
	;;
esac
#!/bin/sh

set -x
set -e

export ADMIN_MODULE_NAME="${ADMIN_MODULE_NAME:-"A Pet Admin"}"
export ADMIN_REST_SERVER_URL="${ADMIN_REST_SERVER_URL:-"localhost:3000/api/v1"}"
export ADMIN_VERSION="${ADMIN_VERSION:-"aor"}"

export SHARED_DIR=${SHARED_DIR:-"/app/shared"}
export OUTPUT_DIR=${OUTPUT_DIR:-"${SHARED_DIR}/generated"}

export RESOURCES_DIR=${RESOURCES_DIR:-"${SHARED_DIR}/resources"}
export RESOURCES_FILENAME=${RESOURCES_FILENAME:-"petstore-aor.json"}
export RESOURCES_FILEPATH=${RESOURCES_FILEPATH:-"${RESOURCES_DIR}/${RESOURCES_FILENAME}"}

export PYTHON_EXEC=$(which python)
export PYTHON3_EXEC=$(which python3)

function clean {
	local output_dir=${1:-"./output"}
	# ls -la ${output_dir} 
	rm -fR $output_dir
	mkdir -p $output_dir
}

export CURRENT_DIR=$(pwd)
export ENTRY=$1

case "$1" in

  'bash')
	apk add --no-cache --no-progress bash nano jq
	export JQ_EXEC=$(which jq)
	export BASH_EXEC=$(which bash)
	export NANO_EXEC=$(which nano)
  	exec /bin/bash $@
	;;

  'dev')
	apk add --no-cache --no-progress bash nano jq gcc musl-dev make cmake openssl-dev libssh2-dev
	export JQ_EXEC=$(which jq)
	export BASH_EXEC=$(which bash)
	export NANO_EXEC=$(which nano)
	export CMAKE_EXEC=$(which cmake)
	export MAKE_EXEC=$(which make)
  	exec /bin/bash $@
	;;

  'demo-aor')
	export ADMIN_VERSION="aor"
	export OUTPUT_DIR="${GENERATE_DIR}/demo/aor"
	clean ${OUTPUT_DIR}
	pwd
	ls -la
	python3 generator.py ${RESOURCES_FILEPATH} ${ADMIN_VERSION} --output-dir=${OUTPUT_DIR} --module-name="${ADMIN_MODULE_NAME}" --rest-server-url="${ADMIN_REST_SERVER_URL}" $@
	;;

  'demo-aor-permissions')
	export ADMIN_VERSION="aor"
	export OUTPUT_DIR="${GENERATE_DIR}/demo/aor-perms"
	clean ${OUTPUT_DIR}
	pwd
	ls -la
	python3 generator.py ${RESOURCES_FILEPATH} ${ADMIN_VERSION} --output-dir=${OUTPUT_DIR} --module-name="${ADMIN_MODULE_NAME}" --rest-server-url="${ADMIN_REST_SERVER_URL}" --permissions $@ $ARGS
	;;

  'demo-ra')
	export ADMIN_VERSION="ra"
	export OUTPUT_DIR="${GENERATE_DIR}/demo/react-admin"
	clean ${OUTPUT_DIR}
	pwd
	ls -la
	exec python3 generator.py ${RESOURCES_FILEPATH} ${ADMIN_VERSION} --output-dir=${OUTPUT_DIR} --module-name="${ADMIN_MODULE_NAME}" --rest-server-url="${ADMIN_REST_SERVER_URL}" $@
	;;

  *)
  	exec /bin/sh $@
	;;
esac
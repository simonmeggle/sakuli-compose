#!/usr/bin/env bash

function main(){
    setvars
    fixPermissions
    echo "Starting docker container: $CONTAINER_NAME"

    docker-compose -f $COMPOSE_FILE kill

    echo "docker-compose -f $COMPOSE_FILE up --force-recreate "
    docker-compose -f $COMPOSE_FILE up --force-recreate
    if [ $? -ne 0 ]; then
	    echo "ERROR: Could not start docker container '$CONTAINER_NAME' in docker-compose file '$COMPOSE_FILE'"
    	exit 1
	fi
}

function fileExistsOrDie(){
	if [ ! -r $1 ]; then
		echo "ERROR: File $1 cannot be found. Exiting. "
		exit 1
	fi
}
function dirExistsOrDie(){
	if [ ! -d $1 ]; then
		echo "ERROR: Directory $1 cannot be found. Exiting. "
		exit 1
	fi
}

function setvars(){
    export CWD=$(readlink -f `dirname $0`)
	export ROOT_NAME=${CWD##*/}
	export PROXY_NETWORK=${ROOT_NAME}_proxy

	PORT_INC=${ARGPORTINC:-0}
	export VNC_PORT=$((5901 + $PORT_INC))
	export VNC_HTTP_PORT=$((6901 + $PORT_INC))

  export WORKSPACE=${ARGWORKSPACE:-$PWD}

	export TESTSUITE=${ARGTESTSUITE:-$TESTSUITE}
	if [ -z "$TESTSUITE" ]; then
		echo "ERROR: No test suite name given. Exiting."
		exit 1
	fi

	# read in common variables
	fileExistsOrDie $CWD/sakuli_compose.rc
	set -a
	. $CWD/sakuli_compose.rc
	set +a

	# read in the suite's .rc file
	if [ -r ${WORKSPACE}/rc.d/${TESTSUITE}.rc ]; then
		set -a
		. ${WORKSPACE}/rc.d/${TESTSUITE}.rc
		set +a
	fi

	# parse additional arguments from .rc file
	for addarg in $(grep "^ADDARG=" ${WORKSPACE}/rc.d/${TESTSUITE}.rc 2> /dev/null); do
		addarg="${addarg/ADDARG=/}"
		ADDARGS="$ADDARGS $addarg"
	done
	ADDARGS="$ADDARGS $ARGADDARGS"
	export ADDARGS

	# HOST
	# suite root path on host
	export TESTSUITES_ROOT_HOST=${ARGTESTSUITES_ROOT:-$TESTSUITES_ROOT}
	export TESTSUITES_ROOT_HOST=${TESTSUITES_ROOT_HOST:-$WORKSPACE/testsuites.example}
	# suite path on host
	export TESTSUITE_FOLDER_HOST=${TESTSUITES_ROOT_HOST}/${TESTSUITE}

	# CONTAINER
	# suite root path within container
	export TESTSUITES_ROOT_MNT=/opt/testsuites
	export TESTSUITE_FOLDER_NMT=${TESTSUITES_ROOT_MNT}/${TESTSUITE}

	export COMPOSE_FILE=${ARGCOMPOSEFILE:-$COMPOSE_FILE}
	# if there is a suite specific compose file, use it
	if [ -r $TESTSUITES_ROOT_HOST/docker-compose-${TESTSUITE}.yml ]; then
		export COMPOSE_FILE=$TESTSUITES_ROOT_HOST/docker-compose-${TESTSUITE}.yml
	fi
	export COMPOSE_FILE=${COMPOSE_FILE:-$WORKSPACE/compose/docker-compose-sakuli.yml}

    export CONTAINER_NAME=sakuli-test-$TESTSUITE

	export COMPOSE_PROJECT_NAME=$TESTSUITE

	export VIRTUAL_TCP_HOST=$CONTAINER_NAME
	export VIRTUAL_TCP_PORT=$VNC_HTTP_PORT

	echo "Loaded variables =================="
	for var in WORKSPACE TESTSUITE TESTSUITE_FOLDER_HOST TESTSUITE_FOLDER_NMT SAHI_FF_PROFILE_TEMPLATE_HOST SAHI_FF_PROFILE_TEMPLATE_MNT SAHI_CERTS_HOST SAHI_CERTS_MNT COMPOSE_FILE  ADD_ARGUMENT; do
		echo "$var: ${!var}"
	done
	dirExistsOrDie $WORKSPACE
	dirExistsOrDie $TESTSUITE_FOLDER_HOST
	echo "==================================="
}

function fixPermissions(){
    var=$TESTSUITES_ROOT_HOST
    echo "fix permissions for: $var"
    find "$var"/ -name '*.sh' -exec chmod -v a+x {} +
    find "$var"/ -name '*.desktop' -exec chmod -v a+x {} +
    chmod -R a+rw "$var" && find "$var" -type d -exec chmod a+wx {} +
}

function usage(){
    echo "$0 - start a sakuli test from docker compose"
    echo "Usage: $0 [-w workspace] [-s suitename] [-c composefile] [-r root] [-p portincr] [-a args]"
    cat <<"EOF"
-w      path to workspace on host (containing the testsuite root folder)
        (env: $WORKSPACE)
-s      name of sakuli suite (a corresponding .rc file can be placed in WORKSPACE/rc.d/)
        (env: $TESTSUITE)
-c      custom docker-compose file (default: docker-compose.yml),
		suite-specific compose files in WORKSPACE/testsuites/docker-compose-TESTSUITE.yml))
        (env: $COMPOSE_FILE)
-r      path to root folder of all test suites (default: WORKSPACE/testsuites)
-p      port incrementation for VNC (based on 5901/6901) (default: 0)
-a      additional arguments passed to the Sakuli starter within the container
        (env: ADDARGS)
EOF
    exit 1
}


while getopts "hs:w:r:c:p:a:" opt; do
  case $opt in
  h)
  	usage
  ;;
  a)
	ARGADDARGS="$OPTARG $ADDARGS"
  ;;
  s)
  	ARGTESTSUITE=$OPTARG
  ;;
  w)
	ARGWORKSPACE=$OPTARG
  ;;
  c)
	ARGCOMPOSEFILE=$OPTARG
  ;;
  r)
	ARGTESTSUITES_ROOT=$OPTARG
  ;;
  p)
	ARGPORTINC=$OPTARG
  ;;
  *)
  echo "Unknown parameter."
  exit 1
  ;;
  esac
done



main

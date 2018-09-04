#!/usr/bin/env bash

# on MacOS, run "brew install coreutils" to get the GNU tools
GREADLINK=$(which greadlink)
READLINK=${GREADLINK:-readlink}

function main() {
	setvars
	while true; do 
		while read suite; do 
			[[ $suite =~ ^# ]] && continue
			$PWD/sakuli_compose.sh -s $suite -p $PORT_INC 
		done <$CHAINFILE
		[ $ARGLOOP -ne 1 ] && exit
	done
}

function usage(){
    echo "$0 - start a chain of sakuli compose tests"
    echo "Usage: $0 [-c chainfile] [-p number] [-l]"
    cat <<"EOF"
-c      chainfile (list of suite names)
-p      port incrementation for VNC (based on 5901/6901)
-l      execute in an endless loop
EOF
    exit 1
}

function setvars(){
	CWDCMD="$READLINK -f $(dirname $0)"
	export CWD=$($CWDCMD)
	if [ -z $ARGCHAINFILE ]; then 
		echo "ERROR: no .rc chain file given. I do not know what chain to execute. Exiting."
		exit 1
	fi 
	PORT_INC=${ARGPORTINC:-0}
	CHAINFILE=$CWD/${ARGCHAINFILE}
	fileExistsOrDie $CHAINFILE
	fileExistsOrDie $PWD/sakuli_compose.sh

}

function fileExistsOrDie(){
	if [ ! -r $1 ]; then 
		echo "ERROR: File $1 cannot be found. Exiting. "
		exit 1
	fi
}

ARGLOOP=0
while getopts "hc:p:l" opt; do
  case $opt in
  h)
  	usage
  ;;
  p) 
	ARGPORTINC=$OPTARG
  ;;
  c)
	ARGCHAINFILE=$OPTARG
  ;;
  l)
 	ARGLOOP=1
  ;;
  *)
  echo "Unknown parameter."
  exit 1
  ;;
  esac
done

main $@

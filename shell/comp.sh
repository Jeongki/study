#!/bin/sh

if [ -z ${1} ]; then
  echo "----- ERROR : Input the program name."
  exit
fi

PGM_NAME=`echo ${1} | cut -d . -f 1`

USER_LIB=SYS1.USERLIB
COB_PATH=${PWD}/COB
CPY_PATH=${PWD}/COPYBOOK

OFCOB_OPT="--enable-cbltdli --notrunc --check-index --force-trace"
RC=-1

echo "1: ofcbpp -i ${COB_PATH}/${PGM_NAME}.cob -o ${COB_PATH}/${PGM_NAME}.cbl -copypath ${CPY_PATH}"
ofcbpp -i ${COB_PATH}/${PGM_NAME}.cob -o ${COB_PATH}/${PGM_NAME}.cbl -copypath ${CPY_PATH}; RC=`echo $?`
if [ ${RC} == 0 ]; then echo "--> Pre-Compile Success";
else                    echo "--> Pre-Compile Fail"; exit 255; fi

echo "2: ofcob -o ${COB_PATH}/${PGM_NAME}.so -g -U ${COB_PATH}/${PGM_NAME}.cbl -L${OPENFRAME_HOME}/lib -ltextfh -lhidb --enable-cbltdli --notrunc --check-index"
ofcob -o ${COB_PATH}/${PGM_NAME}.so -g -U ${COB_PATH}/${PGM_NAME}.cbl -L${OPENFRAME_HOME}/lib -ltextfh -lhidb ${OFCOB_OPT}; RC=`echo $?`
if [ ${RC} == 0 ]; then echo "--> Compile Success";
else                    echo "--> Compile Fail"; exit 255; fi

echo "3: dlupdate ${COB_PATH}/${PGM_NAME}.so ${USER_LIB}"
dlupdate ${COB_PATH}/${PGM_NAME}.so ${USER_LIB}
if [ ${RC} == 0 ]; then echo "--> Update Success";
else                    echo "--> Update Fail"; exit 255; fi

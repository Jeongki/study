#!/bin/sh

## DIRECTORIES PATH
LOG_DIR=${PWD}/LOG
LOG_FILE=${LOG_DIR}/PSB_LOG_`date '+%y%m%d'`
ERR_FILE=${LOG_DIR}/PSB_ERR_`date '+%y%m%d'`
COMP_LOG_FILE=${LOG_DIR}/PSB_COMP_LOG_`date '+%y%m%d'`

PSB_DIR=${PWD}/PSB

SCH_DIR=${OPENFRAME_HOME}/hidb/hidb_sch

## VARIABLES
RC=-1
PSB_TTL_CNT=0
PSB_SUC_CNT=0
PSB_ERR_CNT=0

DLI_SUC_CNT=0
DLI_ERR_CNT=0

## PREPARATION
if [ ! -d ${LOG_DIR}       ]; then mkdir ${LOG_DIR};                                       fi
if [   -e ${LOG_FILE}      ]; then rm ${LOG_FILE};                                         fi
if [   -e ${COMP_LOG_FILE} ]; then rm ${COMP_LOG_FILE};                                    fi
if [   -e ${ERR_FILE}      ]; then rm ${ERR_FILE};                                         fi

## INTERNAL FUNCTIONS
_usage(){
 echo ""
 echo "[ DBDGEN script ]"
 echo " Usage             : PSB directory is necessary."
 echo "                     `basename "$0"`"
 echo ""
 echo " Options"
 echo "   -h              : Display usage information"
 echo ""
 exit ${1}
}

_report(){
 echo -e "\e[35m------------------------[ REPORT ]------------------------\e[m"
 echo -e "\e[35m-\e[m \e[34m[ PSBGEN ]\e[m"
 echo -e "\e[35m-\e[m      Total        : ${PSB_TTL_CNT}"
 echo -e "\e[35m-\e[m      Success      :" `expr ${PSB_TTL_CNT} - ${PSB_ERR_CNT} - ${DLI_ERR_CNT}`
 echo -e "\e[35m-\e[m      Psbgen Error : ${PSB_ERR_CNT}"
 echo -e "\e[35m-\e[m      Dligen Error : ${DLI_ERR_CNT}"
 echo -e "\e[35m----------------------------------------------------------\e[m"
}

_compile_pc(){
 echo -n "***************************************** COMPMODL " >> ${COMP_LOG_FILE}
 echo "*****************************************" >> ${COMP_LOG_FILE}
 echo "[ Command : sh compile.sh ${1} ]" >> ${COMP_LOG_FILE}
 echo -n " +compile ---> "

 cd ${SCH_DIR}
 sh one_compile.sh ${1} >> ${COMP_LOG_FILE} 2>&1; RC=`echo $?`
 cd - > /dev/null

 if [ ${RC} != 0 ]; then
   echo -e "\e[91m[ERROR]\e[m   : *${1}*.pc >> ${COMP_LOG_FILE}"
   echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! COMPMODL " >> ${COMP_LOG_FILE}
   echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${COMP_LOG_FILE}
   return
 else
   echo -e "\e[92m[SUCCESS]\e[m : *${1}*.pc"
   echo -n "***************************************** COMPMODL " >> ${COMP_LOG_FILE}
   echo "*****************************************" >> ${COMP_LOG_FILE}
 fi
}

_psbgen(){
 psb_file=${1}

 echo -n "****************************************** PSBGEN " >> ${LOG_FILE}
 echo "******************************************" >> ${LOG_FILE}
 echo "[ Command : psbgen -f ${PSB_DIR}/${psb_file} ]" >> ${LOG_FILE}
 echo -n "psbgen ------> "

 psbgen -f ${PSB_DIR}/${psb_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`

 if [ ${RC} != 0 ]; then
   echo -e "\e[91m[ERROR]\e[m   : ${psb_file} >> ${ERR_FILE}"
   echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! GENERR " >> ${LOG_FILE}
   echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
   PSB_ERR_CNT=$((${PSB_ERR_CNT} + 1))
   return
 else
   echo -e "\e[92m[SUCCESS]\e[m : ${psb_file}"
   echo -n "****************************************** GENEND " >> ${LOG_FILE}
   echo "******************************************" >> ${LOG_FILE}
   PSB_SUC_CNT=$((${DBD_SUC_CNT} + 1))
 fi

 echo -n "****************************************** DLIGEN " >> ${LOG_FILE}
 echo "******************************************" >> ${LOG_FILE}
 echo "[ Command : hidbmgr psb dligen ${psb_file} ]" >> ${LOG_FILE}
 echo -n "dligen ------> "

 cd ${PSB_DIR}
 hidbmgr psb dligen ${psb_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`
 cd - > /dev/null

 if [ ${RC} != 0 ]; then
   echo -e "\e[91m[ERROR]\e[m   : ${psb_file} >> ${ERR_FILE}"
   echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! GENERR " >> ${LOG_FILE}
   echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
   DLI_ERR_CNT=$((${DLI_ERR_CNT} + 1))
   return
 else
   echo -e "\e[92m[SUCCESS]\e[m : ${psb_file}"
   echo -n "****************************************** GENEND " >> ${LOG_FILE}
   echo "******************************************" >> ${LOG_FILE}
   DLI_SUC_CNT=$((${DLI_SUC_CNT} + 1))
 fi

 _compile_pc ${psb_file}
}

####################################################################################
##                                 MAIN PROCEDURE                                 ##
####################################################################################
while getopts "h" opt
do
  case ${opt} in
    h) _usage 0;;
  esac
done

for psb_file in `ls ${PSB_DIR}`
do
  if [ -z ${psb_file} ]; then exit 255; fi

  _psbgen ${psb_file}

  PSB_TTL_CNT=$((${PSB_TTL_CNT} + 1))
done

_report

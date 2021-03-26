#!/bin/sh

## DIRECTORIES PATH
LOG_DIR=${PWD}/LOG
LOG_FILE=${LOG_DIR}/DBD_LOG_`date '+%y%m%d'`
ERR_FILE=${LOG_DIR}/DBD_ERR_`date '+%y%m%d'`
COMP_LOG_FILE=${LOG_DIR}/DBD_COMP_LOG_`date '+%y%m%d'`

DBD_DIR=${PWD}/DBD
PHY_DIR=${DBD_DIR}/PHYSICAL
IDX_DIR=${DBD_DIR}/INDEX
LGC_DIR=${DBD_DIR}/LOGICAL

CPY_DIR=${OPENFRAME_HOME}/hidb/hidb_cpy
SCH_DIR=${OPENFRAME_HOME}/hidb/hidb_sch

COMP_CPY_DIR=${PWD}/COPYBOOK

## VARIABLES
RC=-1
PLAINRUN=N
CPYBKGEN=N
SCHEMGEN=N
TABLEGEN=N

DBDGEN_ERR=
DBD_TTL_CNT=0
DBD_SUC_CNT=0
DBD_ERR_CNT=0

CPYBKGEN_ERR=
CPY_TTL_CNT=0
CPY_SUC_CNT=0
CPY_ERR_CNT=0

HDGEN_ERR=
HDG_TTL_CNT=0
HDG_SUC_CNT=0
HDG_ERR_CNT=0

TBLGEN_ERR=
TBL_TTL_CNT=0
TBL_SUC_CNT=0
TBL_ERR_CNT=0

FKGEN_ERR=
FKG_TTL_CNT=0
FKG_SUC_CNT=0
FKG_ERR_CNT=0

PCCOM_ERR=
COM_TTL_CNT=0
COM_SUC_CNT=0
COM_ERR_CNT=0

## DB CONNECTION
USERID=tibero
USERPW=
DBSID=tbdb

## PREPARTION
if [ ! -d ${LOG_DIR}       ]; then mkdir ${LOG_DIR};                                       fi
if [   -e ${LOG_FILE}      ]; then rm ${LOG_FILE};                                         fi
if [   -e ${COMP_LOG_FILE} ]; then rm ${COMP_LOG_FILE};                                    fi
if [   -e ${ERR_FILE}      ]; then rm ${ERR_FILE};                                         fi
if [ ! -d ${PHY_DIR}       ]; then echo "Check Physical DBD."; mkdir ${PHY_DIR}; exit 255; fi
if [ ! -d ${IDX_DIR}       ]; then mkdir ${IDX_DIR};                                       fi
if [ ! -d ${LGC_DIR}       ]; then mkdir ${LGC_DIR};                                       fi
if [ ! -d ${COMP_CPY_DIR}  ]; then mkdir ${COMP_CPY_DIR};                                  fi

## INTERNAL FUNCTIONS
_dbdgen(){
 for dbd_file in `ls ${1}`
 do
   if [ -z ${dbd_file} ]; then return; fi

   echo -n "****************************************** DBDGEN " >> ${LOG_FILE}
   echo "******************************************" >> ${LOG_FILE}
   echo "[ Command : dbdgen -f ${1}/${dbd_file} ]" >> ${LOG_FILE}
   echo -n "dbdgen ------> "

   dbdgen -f ${1}/${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`

   if [ ${RC} != 0 ]; then
     echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
     echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! GENERR " >> ${LOG_FILE}
     echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
     DBDGEN_ERR=${DBDGEN_ERR}' '${dbd_file}; DBD_ERR_CNT=$((${DBD_ERR_CNT} + 1))
   else
     echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
     echo -n "****************************************** GENEND " >> ${LOG_FILE}
     echo "******************************************" >> ${LOG_FILE}
     DBD_SUC_CNT=$((${DBD_SUC_CNT} + 1))
   fi
   DBD_TTL_CNT=$((${DBD_TTL_CNT} + 1))
 done
}

_cpybkgen(){
 # PHYSICAL DBD
 for dbd_file in `ls ${PHY_DIR}`
 do
   if [[ "${DBDGEN_ERR}" == *"${dbd_file}"* ]]; then continue; fi

   echo -n "**************************************** DBDCPBKGEN " >> ${LOG_FILE}
   echo "****************************************" >> ${LOG_FILE}
   echo "[ Command : dbdcpybkgen ${PHY_DIR}/${dbd_file} ]" >> ${LOG_FILE}
   echo -n "dbdcpybkgen -> "

   dbdcpybkgen ${PHY_DIR}/${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`

   if [ ${RC} != 0 ]; then
     echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
     echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CPBKGENERR " >> ${LOG_FILE}
     echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
     CPYBKGEN_ERR=${CPYBKGEN_ERR}' '${dbd_file}; CPY_ERR_CNT=$((${CPY_ERR_CNT} + 1))
   else
     echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
     echo -n "**************************************** CPBKGENEND " >> ${LOG_FILE}
     echo "****************************************" >> ${LOG_FILE}
     CPY_SUC_CNT=$((${CPY_SUC_CNT} + 1))
   fi

   CPY_TTL_CNT=$((${CPY_TTL_CNT} + 1))
 done

 # SECONDARY INDEX
 for dbd_file in `ls ${IDX_DIR}`
 do
   if [[ "${DBDGEN_ERR}" == *"${dbd_file}"* ]]; then continue; fi

   RC=-1
   grep -A 3 "${dbd_file}" ${PHY_DIR}/* > .tmp.txt

   while read line
   do
     if [ ${RC} == 0 ]; then
       echo ${line} | grep "LCHILD" > /dev/null; RC=`echo $?`
       if [ ${RC} == 0 ]; then
         #echo "${dbd_file} is not secondary."
         break
       fi
       echo ${line} | grep "XDFLD" > /dev/null; RC=`echo $?`
       if [ ${RC} == 0 ]; then
         echo -n "**************************************** DBDCPBKGEN " >> ${LOG_FILE}
         echo "****************************************" >> ${LOG_FILE}
         echo "[ Command : dbdcpybkgen ${IDX_DIR}/${dbd_file} ]" >> ${LOG_FILE}
         echo -n "dbdcpybkgen -> "

         dbdcpybkgen ${IDX_DIR}/${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`

         if [ ${RC} != 0 ]; then
           echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
           echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CPBKGENERR " >> ${LOG_FILE}
           echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
           CPYBKGEN_ERR=${CPYBKGEN_ERR}' '${dbd_file}; CPY_ERR_CNT=$((${CPY_ERR_CNT} + 1))
         else
           echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
           echo -n "**************************************** CPBKGENEND " >> ${LOG_FILE}
           echo "****************************************" >> ${LOG_FILE}
           CPY_SUC_CNT=$((${CPY_SUC_CNT} + 1))
         fi

         CPY_TTL_CNT=$((${CPY_TTL_CNT} + 1))

         break
       else
         continue
       fi
     else
       echo ${line} | egrep "${dbd_file}" | egrep "LCHILD" > /dev/null ; RC=`echo $?`
     fi
   done < .tmp.txt
   rm .tmp.txt
 done
}

_hdgensch(){
 for dbd_file in `ls ${1}`
 do
   if [[ "${DBDGEN_ERR}"   == *"${dbd_file}"* ]]; then continue; fi
   if [[ "${CPYBKGEN_ERR}" == *"${dbd_file}"* ]]; then continue; fi
   
   echo ${1} | grep "DBD/PHYSICAL" > /dev/null; RC=`echo $?`
   if [ ${RC} == 0 ]; then
   # PHYSICAL
     echo -n "***************************************** HDGENSCH " >> ${LOG_FILE}
     echo "*****************************************" >> ${LOG_FILE}
     echo -n "hdgensch ----> "

     cd ${PHY_DIR}
     if [ SCHEMGEN == N ]; then
       echo "[ Command : hdgensch meta ${dbd_file} ]" >> ${LOG_FILE}
       hdgensch meta ${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`
     else
       echo "[ Command : hdgensch all  ${dbd_file} ]" >> ${LOG_FILE}
       hdgensch all  ${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`
     fi
     cd - > /dev/null

     if [ ${RC} != 0 ]; then
       echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
       echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! HDGENERR " >> ${LOG_FILE}
       echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
       HDGEN_ERR=${HDGEN_ERR}' '${dbd_file}; HDG_ERR_CNT=$((${HDG_ERR_CNT} + 1))
     else
       echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
       echo -n "***************************************** HDGENEND " >> ${LOG_FILE}
       echo "*****************************************" >> ${LOG_FILE}
       HDG_SUC_CNT=$((${HDG_SUC_CNT} + 1))
     fi

     HDG_TTL_CNT=$((${HDG_TTL_CNT} + 1))
   else
   # SECONDARY INDEX
     RC=-1
     grep -A 3 "${dbd_file}" ${PHY_DIR}/* > .tmp.txt

     while read line
     do
       if [ ${RC} == 0 ]; then
         echo ${line} | grep "LCHILD" > /dev/null; RC=`echo $?`
         if [ ${RC} == 0 ]; then
           #echo "${dbd_file} is not secondary."
           break
         fi

         echo ${line} | grep "XDFLD" > /dev/null; RC=`echo $?`
         if [ ${RC} == 0 ]; then
           echo -n "***************************************** HDGENSCH " >> ${LOG_FILE}
           echo "*****************************************" >> ${LOG_FILE}
           echo -n "hdgensch ----> "

           cd ${IDX_DIR}
           if [ SCHEMGEN == N ]; then
             echo "[ Command : hdgensch meta ${dbd_file} ]" >> ${LOG_FILE}
             hdgensch meta ${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`
           else
             echo "[ Command : hdgensch all  ${dbd_file} ]" >> ${LOG_FILE}
             hdgensch all  ${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`
           fi
           cd - > /dev/null

           if [ ${RC} != 0 ]; then
             echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
             echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! HDGENERR " >> ${LOG_FILE}
             echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
             HDGEN_ERR=${HDGEN_ERR}' '${dbd_file}; HDG_ERR_CNT=$((${HDG_ERR_CNT} + 1))
           else
             echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
             echo -n "***************************************** HDGENEND " >> ${LOG_FILE}
             echo "*****************************************" >> ${LOG_FILE}
             HDG_SUC_CNT=$((${HDG_SUC_CNT} + 1))
           fi

           HDG_TTL_CNT=$((${HDG_TTL_CNT} + 1))

           break
         else
           continue
         fi
       else
         echo ${line} | egrep "${dbd_file}" | egrep "LCHILD" > /dev/null; RC=`echo $?`
       fi
     done < .tmp.txt
     rm .tmp.txt
   fi
 done
}

_fk_create(){
 if [[ "${TBLGEN_ERR}"   == *"${1}"* ]]; then return; fi

 LDBD_SEARCH_QUERY=`tbsql ${USERID}/${USERPW}@${DBSID} << EOF
select distinct LDBD_NAME from OFM_HIDB_DBD_SEGMENT where DBD_NAME = '${1}' and LDBD_NAME is not null and DBD_LIB_NAME = 'IMS.DBDLIB';
EOF`

 echo ${LDBD_SEARCH_QUERY} | grep "0 row" > /dev/null; RC=`echo $?`
 if [ ${RC} == 0 ]; then return; fi

 LDBD_LIST=$(echo ${LDBD_SEARCH_QUERY} | sed -e 's/.*---- \(.*\).*[0-9].*row.*/\1/')
 if [ -z ${LDBD_LIST} ]; then return; fi

 for ldbd in ${LDBD_LIST}
 do
   echo -n "**************************************** FKCONSTGEN " >> ${LOG_FILE}
   echo "****************************************" >> ${LOG_FILE}
   echo "[ Command : hidbmgr segm create ${ldbd} -fk ]" >> ${LOG_FILE}
   echo -n " +fk const --> "

   hidbmgr segm create ${ldbd} -fk 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`

   if [ ${RC} != 0 ]; then
     echo -e "\e[91m[ERROR]\e[m   : ${ldbd} >> ${ERR_FILE}"
     echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! FKGENERR " >> ${LOG_FILE}
     echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
     FKGEN_ERR=${FKGEN_ERR}' '${dbd_file}; FKG_ERR_CNT=$((${FKG_ERR_CNT} + 1))
   else
     echo -e "\e[92m[SUCCESS]\e[m : ${ldbd}"
     echo -n "***************************************** FKGENEND " >> ${LOG_FILE}
     echo "*****************************************" >> ${LOG_FILE}
     FKG_SUC_CNT=$((${FKG_SUC_CNT} + 1))
   fi

   FKG_TTL_CNT=$((${FKG_TTL_CNT} + 1))
 done
}

_hidbmgr_create() {
 for target_dir in ${PHY_DIR} ${IDX_DIR} ${LGC_DIR}
 do
   for dbd_file in `ls ${target_dir}`
   do
     if [[ "${DBDGEN_ERR}" == *"${dbd_file}"* ]]; then continue; fi
     if [[ "${HDGEN_ERR}" == *"${dbd_file}"* ]]; then continue; fi

     echo ${target_dir} | grep "DBD/INDEX" > /dev/null; RC=`echo $?`
     if [ ${RC} != 0 ]; then
       echo -n "***************************************** HDSEGGEN " >> ${LOG_FILE}
       echo "*****************************************" >> ${LOG_FILE}
       echo "[ Command : hidbmgr segm create ${dbd_file} -f ]" >> ${LOG_FILE}
       echo -n "hdmgr segm --> "

       cd ${target_dir}
       hidbmgr segm create ${dbd_file} -f 1>> ${LOG_FILE} 2>> ${ERR_FILE}
       RC=`echo $?`
       cd - > /dev/null

       if [ ${RC} != 0 ]; then
         echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
         echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! HDGENERR " >> ${LOG_FILE}
         echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
         TBLGEN_ERR=${TBLGEN_ERR}' '${dbd_file}; TBL_ERR_CNT=$((${TBL_ERR_CNT} + 1))
       else
         echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
         echo -n "***************************************** HDGENEND " >> ${LOG_FILE}
         echo "*****************************************" >> ${LOG_FILE}
         TBL_SUC_CNT=$((${TBL_SUC_CNT} + 1))
       fi

       TBL_TTL_CNT=$((${TBL_TTL_CNT} + 1))
     else
       RC=-1
       grep -A 3 "${dbd_file}" ${PHY_DIR}/* > .tmp.txt

       while read line
       do
         if [ ${RC} == 0 ]; then
           echo ${line} | egrep "LCHILD" > /dev/null; RC=`echo $?`
           if [ ${RC} == 0 ]; then
             #echo "${dbd_file} is primary."
             break
           fi

           echo ${line} | egrep "XDFLD" > /dev/null; RC=`echo $?`
           if [ ${RC} == 0 ]; then
             #echo "${dbd_file} is secondary."
             echo -n "***************************************** HDSEGGEN " >> ${LOG_FILE}
             echo "*****************************************" >> ${LOG_FILE}
             echo "[ Command : hidbmgr segm create ${dbd_file} -f ]" >> ${LOG_FILE}
             echo -n "hdmgr segm --> "
             
             cd ${target_dir}
             hidbmgr segm create ${dbd_file} -f 1>> ${LOG_FILE} 2>> ${ERR_FILE}
             RC=`echo $?`
             cd - > /dev/null

             if [ ${RC} != 0 ]; then
               echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
               echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! HDGENERR " >> ${LOG_FILE}
               echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
               TBLGEN_ERR=${TBLGEN_ERR}' '${dbd_file}; TBL_ERR_CNT=$((${TBL_ERR_CNT} + 1))
             else
               echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
               echo -n "***************************************** HDGENEND " >> ${LOG_FILE}
               echo "*****************************************" >> ${LOG_FILE}
               TBL_SUC_CNT=$((${TBL_SUC_CNT} + 1))
             fi

             TBL_TTL_CNT=$((${TBL_TTL_CNT} + 1))

             break
           else
             #echo "Can't define ${dbd_file} is primary or secondary yet."
             continue
           fi
         else
           echo ${line} | egrep "${dbd_file}" | egrep "LCHILD" > /dev/null; RC=`echo $?`
         fi
       done < .tmp.txt
       rm .tmp.txt
     fi

     _fk_create ${dbd_file};
   done
 done
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
   PCCOM_ERR=${PCCOM_ERR}' '${dbd_file}; COM_ERR_CNT=$((${COM_ERR_CNT} + 1))
 else
   echo -e "\e[92m[SUCCESS]\e[m : *${1}*.pc"
   echo -n "***************************************** COMPMODL " >> ${COMP_LOG_FILE}
   echo "*****************************************" >> ${COMP_LOG_FILE}
   COM_SUC_CNT=$((${COM_SUC_CNT} + 1))
 fi

 COM_TTL_CNT=$((${COM_TTL_CNT} + 1))
}

_dligen(){
 for dbd_file in `ls ${1}`
 do
   if [[ "${DBDGEN_ERR}" == *"${dbd_file}"* ]]; then continue; fi
   if [[ "${TBLGEN_ERR}" == *"${dbd_file}"* ]]; then continue; fi

   echo ${1} | grep "DBD/INDEX" > /dev/null; RC=`echo $?`
   if [ ${RC} != 0 ]; then
   # PHYSICAL
     echo -n "****************************************** DLIGEN " >> ${LOG_FILE}
     echo "******************************************" >> ${LOG_FILE}
     echo -n "dligen ------> "

     cd ${PHY_DIR}
     hidbmgr dbd dligen ${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`
     cd - > /dev/null

     if [ ${RC} != 0 ]; then
       echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
       echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! DLIERR " >> ${LOG_FILE}
       echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
     else
       echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
       echo -n "****************************************** DLIEND " >> ${LOG_FILE}
       echo "******************************************" >> ${LOG_FILE}

       cp ${CPY_DIR}/${dbd_file}/* ${COMP_CPY_DIR}/
       _compile_pc ${dbd_file}
     fi
   else
   # SECONDARY INDEX
     RC=-1
     grep -A 3 "${dbd_file}" ${PHY_DIR}/* > .tmp.txt

     while read line
     do
       if [ ${RC} == 0 ]; then
         echo ${line} | grep "LCHILD" > /dev/null; RC=`echo $?`
         if [ ${RC} == 0 ]; then
           break
         fi

         echo ${line} | grep "XDFLD" > /dev/null; RC=`echo $?`
         if [ ${RC} == 0 ]; then
           echo -n "***************************************** HDGENSCH " >> ${LOG_FILE}
           echo "*****************************************" >> ${LOG_FILE}
           echo -n "dligen ------> "

           cd ${IDX_DIR}
           hidbmgr dbd dligen ${dbd_file} 1>> ${LOG_FILE} 2>> ${ERR_FILE}; RC=`echo $?`
           cd - > /dev/null

           if [ ${RC} != 0 ]; then
             echo -e "\e[91m[ERROR]\e[m   : ${dbd_file} >> ${ERR_FILE}"
             echo -n "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! DLIERR " >> ${LOG_FILE}
             echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${LOG_FILE}
           else
             echo -e "\e[92m[SUCCESS]\e[m : ${dbd_file}"
             echo -n "****************************************** DLIEND " >> ${LOG_FILE}
             echo "******************************************" >> ${LOG_FILE}

             cp ${CPY_DIR}/${dbd_file}/* ${COMP_CPY_DIR}/
             _compile_pc ${dbd_file}
           fi

           break
         else
           continue
         fi
       else
         echo ${line} | egrep "${dbd_file}" | egrep "LCHILD" > /dev/null; RC=`echo $?`
       fi
     done < .tmp.txt
     rm .tmp.txt
   fi
 done
}

_usage(){
 echo ""
 echo "[ DBDGEN script ]"
 echo " Usage             : DBD/PHYSICAL, INDEX, LOGICAL directories are necessary."
 echo "                     Must specify one option at least."
 echo "                     `basename "$0"` [option]"
 echo ""
 echo " Options"
 echo "   -h              : Display usage information"
 echo "   -c              : Use when required to create copybook."
 echo "   -s              : Use when required to create schema file."
 echo "   -t              : Use when required to create table."
 echo "   -p <password>   : Insert the password of DB. (Option)"
 echo "   -r              : Only refresh meta data and compile pc files."
 echo ""
 echo " Example"
 echo "   `basename "$0"` -r    : Execute dbdgen, hdgensch, dligen only (Default)."
 echo "   `basename "$0"` -c    : Include dbdcpybkgen step."
 echo "   `basename "$0"` -t    : Include hidbmgr segm create step."
 echo "   `basename "$0"` -c -t : Include the two step above."
 echo "   ..."
 echo ""
 exit ${1}
}

_report(){
 echo -e "\e[35m------------------------[ REPORT ]------------------------\e[m"
 echo -e "\e[35m-\e[m \e[34m[ DBDGEN ]\e[m"
 echo -e "\e[35m-\e[m      Total   : ${DBD_TTL_CNT}"
 echo -e "\e[35m-\e[m      Success : ${DBD_SUC_CNT}"
 echo -e "\e[35m-\e[m      Error   : ${DBD_ERR_CNT}"
 if [ ${CPYBKGEN} == Y ]; then
   echo -e "\e[35m-\e[m \e[34m[ DBDCPYBKGEN ]\e[m"
   echo -e "\e[35m-\e[m      Total   : ${CPY_TTL_CNT}"
   echo -e "\e[35m-\e[m      Success : ${CPY_SUC_CNT}"
   echo -e "\e[35m-\e[m      Error   : ${CPY_ERR_CNT}"
 fi
 echo -e "\e[35m-\e[m \e[34m[ HDGENSCH ]\e[m"
 echo -e "\e[35m-\e[m      Total   : ${HDG_TTL_CNT}"
 echo -e "\e[35m-\e[m      Success : ${HDG_SUC_CNT}"
 echo -e "\e[35m-\e[m      Error   : ${HDG_ERR_CNT}"
 if [ ${TABLEGEN} == Y ]; then
   echo -e "\e[35m-\e[m \e[34m[ HIDBMGR SEGM CREATE ]\e[m"
   echo -e "\e[35m-\e[m      Total   : ${TBL_TTL_CNT}"
   echo -e "\e[35m-\e[m      Success : ${TBL_SUC_CNT}"
   echo -e "\e[35m-\e[m      Error   : ${TBL_ERR_CNT}"
   if [ ${FKG_TTL_CNT} != 0 ]; then
     echo -e "\e[35m-\e[m \e[34m[ HIDBMGR SEGM CREATE FOREIGN KEY ]\e[m"
     echo -e "\e[35m-\e[m      Total   : ${FKG_TTL_CNT}"
     echo -e "\e[35m-\e[m      Success : ${FKG_SUC_CNT}"
     echo -e "\e[35m-\e[m      Error   : ${FKG_ERR_CNT}"
   fi
 fi
 echo -e "\e[35m-\e[m \e[34m[ HIDBMGR DBD DLIGEN & COMPILE ]\e[m"
 echo -e "\e[35m-\e[m      Total   : ${COM_TTL_CNT}"
 echo -e "\e[35m-\e[m      Success : ${COM_SUC_CNT}"
 echo -e "\e[35m-\e[m      Error   : ${COM_ERR_CNT}"
 echo -e "\e[35m----------------------------------------------------------\e[m"
}

####################################################################################
##                                 MAIN PROCEDURE                                 ##
####################################################################################
while getopts "p:hcstr" opt
do
  case ${opt} in
    h) _usage 0;;
    p) export USERPW=${OPTARG};;
    c) export CPYBKGEN=Y; export PLAINRUN=Y;;
    s) export SCHEMGEN=Y; export PLAINRUN=Y;;
    t) export TABLEGEN=Y; export PLAINRUN=Y;;
    r) export PLAINRUN=Y; export PLAINRUN=Y;;
    *) _usage 255;;
  esac
done

if [ ${PLAINRUN} == N ]; then
  _usage 255
fi

if [ -z ${USERPW} ] && [ ${TABLEGEN} == Y ]; then
  echo "- The database password is required to re-create table."
  echo -n "- Input database password : "
  read WORD
  USERPW=${WORD}
fi

## PHASE 1
for target_dir in ${PHY_DIR} ${IDX_DIR} ${LGC_DIR}
do 
  _dbdgen ${target_dir}
done

## PHASE 2
if [ ${CPYBKGEN} == Y ]; then
  echo -e "\e[31m[[WARNING]]\e[m"
  echo "- This process will re-create copybooks for DBD in PHYSICAL and INDEX."
  echo "- If there's already existing copybooks for that DBD, recommend to stop."
  echo "- Mostly, this tool is used when DBD is variable type not fixed."
  echo -n "- Are you sure to run it? (Y/N) : "
  read WORD

  case ${WORD} in
    [yY]) _cpybkgen;;
    [nN]) echo "Stop the script."; exit 0;;
       *) echo "Input wrong character."; exit 255;;
  esac 
fi

## PHASE 3
for target_dir in ${PHY_DIR} ${IDX_DIR}
do
  _hdgensch ${target_dir}
done

## PHASE 4
if [ ${TABLEGEN} == Y ]; then
  echo -e "\e[31m[[WARNING]]\e[m"
  echo "- This process will re-create tables for DBD in PHYSICAL and INDEX."
  echo "- If the data can't be restored after this process, recommend to stop."
  echo "- Even though, if you want to continue, please back up the data."
  echo -n "- Are you sure to run it? (Y/N) : "
  read WORD

  case ${WORD} in
    [yY]) _hidbmgr_create;;
    [nN]) echo "Stop the script."; exit 0;;
       *) echo "Input wrong character."; exit 255;;
  esac
fi

## PHASE 5
for target_dir in ${PHY_DIR} ${IDX_DIR} ${LGC_DIR}
do
  _dligen ${target_dir}
done

## PHASE 6
_report

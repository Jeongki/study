#!/bin/sh

# !! USAGE WARNING !!
# 1. MUST KEEP 8 BYTES LENGTH FOR SEGMENT NAME LENGTH
# 2. MUST PUT '(' TRANSPARENT RIGHT BEHIND OF SEGMENT NAME
# 3. MUST KEEP 8 BYTES LENGTH FOR SEGMENT FIELD NAME LENGTH
# 4. MUST PUT ' ' BLANK RIGHT BEHIND OF SEGMENT FIELD NAME
# EX) GHU -s "SEGM1   (S1_KEY   =1001)"

# PHASE1 : Insert into SEGM1 of D4SAMP01
_init_SEGM1(){
echo "START SEGM1"
 for ID in {1..3}
 do
cat > .ghu.tmp << EOF
GHU  -s "SEGM1   (S1_KEY   =   ${ID})"
QUIT
EOF
   echo "Command : GHU  -s \"SEGM1   (S1_KEY   =   ${ID})\""
   hidbcmd -d D4SAMP01 < .ghu.tmp 1> .rst.tmp
   RTCD=`grep "STATUS CODE" .rst.tmp | sed 's/.*STATUS CODE=\(.\+\)(.*/\1/'`
   rm .ghu.tmp .rst.tmp

   if [ "${RTCD}" == "  " ]; then
cat > .dlet.tmp << EOF
GHU  -s "SEGM1   (S1_KEY   =   ${ID})"
DLET -s "SEGM1   (S1_KEY   =   ${ID})"
QUIT
EOF
     echo "Command : DLET -s \"SEGM1   (S1_KEY   =   ${ID})\""
     hidbcmd -d D4SAMP01 < .dlet.tmp 1> /dev/null; rm .dlet.tmp
   fi

cat > .isrt.tmp << EOF
ISRT -s "SEGM1   " -i "   ${ID}DATA${ID}"
QUIT
EOF
   echo "Command : ISRT -s \"SEGM1   \" -i \"   ${ID}DATA${ID}\""
   hidbcmd -d D4SAMP01 < .isrt.tmp 1> /dev/null; rm .isrt.tmp
 done
}

# PHASE2 : Insert into SEGM3 of D4SAMP02
_init_SEGM3(){
echo "START SEGM3"
 for ID in {4..6}
 do
cat > .ghu.tmp << EOF
GHU  -s "SEGM3   (S3_KEY   =     ${ID})"
EOF
   echo "Command : GHU  -s \"SEGM3   (S3_KEY   =     ${ID})\""
   hidbcmd -d D4SAMP02 < .ghu.tmp 1> .rst.tmp
   RTCD=`grep "STATUS CODE" .rst.tmp | sed 's/.*STATUS CODE=\(.\+\)(.*/\1/'`
   rm .ghu.tmp .rst.tmp

   if [ "${RTCD}" == "  " ]; then
cat > .dlet.tmp << EOF
GHU  -s "SEGM3   (S3_KEY   =     ${ID})"
DLET -s "SEGM3   (S3_KEY   =     ${ID})"
QUIT
EOF
     echo "Command : DLET -s \"SEGM3   (S3_KEY   =     ${ID})\""
     hidbcmd -d D4SAMP02 < .dlet.tmp 1> /dev/null; rm .dlet.tmp
   fi

cat > .isrt.tmp << EOF
ISRT -s "SEGM3   " -i "     ${ID}   DATA${ID}"
QUIT
EOF
   echo "Command : ISRT -s \"SEGM3   \" -i \"     ${ID}   DATA${ID}\""
   hidbcmd -d D4SAMP02 < .isrt.tmp 1> /dev/null; rm .isrt.tmp
 done
}

# PHASE3 : Insert into SEGM2 of D4SAMP01
_init_SEGM2(){
echo "START SEGM2"
 for ID in {4..6}
 do
cat > .ghu.tmp << EOF
GHU  -s "SEGM2   (S2_KEY   =     ${ID})"
EOF
   echo "Command : GHU  -s \"SEGM2   (S2_KEY   =     ${ID})\""
   hidbcmd -d D4SAMP01 < .ghu.tmp 1> .rst.tmp
   RTCD=`grep "STATUS CODE" .rst.tmp | sed 's/.*STATUS CODE=\(.\+\)(.*/\1/'`
   rm .ghu.tmp .rst.tmp

   if [ "${RTCD}" == "  " ]; then
cat > .dlet.tmp << EOF
GHU  -s "SEGM2   (S2_KEY   =     ${ID})"
DLET -s "SEGM2   (S2_KEY   =     ${ID})"
QUIT
EOF
     echo "Command : DLET -s \"SEGM2   (S2_KEY   =     ${ID})\""
     hidbcmd -d D4SAMP01 < .dlet.tmp 1> /dev/null; rm .dlet.tmp
   fi

cat > .isrt.tmp << EOF
GHU  -s "SEGM1   (S1_KEY   =   $((ID - 3)))"
ISRT -s "SEGM2   " -i "     ${ID}D$((ID + 3))"
QUIT
EOF
   echo "Command : ISRT -s \"SEGM2   \" -i \"     ${ID}D$((ID + 3))\""
   hidbcmd -d D4SAMP01 < .isrt.tmp 1> /dev/null; rm .isrt.tmp
 done
}

# MAIN
_init_SEGM1
_init_SEGM3
_init_SEGM2


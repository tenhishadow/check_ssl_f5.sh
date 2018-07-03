#!/bin/bash

##############################
# file: "check_ssl_f5.sh"
# script for checking and notifying soon expiration ssl-certificates on F5
# by Stanislav Cherkasov
# Stanislav.Cherkasov.GDC@ts.fujitsu.com
##############################

exec 1>>check_ssl_f5.log
exec 2>>check_ssl_f5.log

### Vars
##############################
IFS='}'
DBG=$( echo "$0 DEBUG: " )                              # customize debug message
WWW=$( echo "$0 WARNING: " )                            # customize warning message
ERR=$( echo "$0 ERROR: " )                              # customize error message
SSL_DUE="22"                                            # check if DATENOW less then SSL_DUE
LOGGER_ARGS=" -p local0.4 -t CUSTOM "                   # args for logger

## Bins
##############################
DATE=$( which date )
GREP=$( which grep )
AWK=$( which awk )
LOGGER=$( which logger )
TMSH=$( which tmsh )


### Functions
##############################
function report {
  echo $1                                               # simple message
  #$LOGGER $LOGGER_ARGS "$1"                            # syslog message
  [[ $FATAL == 1 ]] && exit 1                           # exit script in case of FATAL error
}

function date_diff {
  DATENOW=$( $DATE "+%s" )                              # now in unix epoch
  DATE_TO_DIFF=$( $DATE -d "$1" "+%s" )                 # SSL_EXP in unix epoch
  DATEDIFF=$(( ( DATE_TO_DIFF - DATENOW ) / 86400 ))    # days to expire

  # Report in case of soon expiration
  LOGGER_MESSAGE="$WWW $SSL_CRT will expire at $SSL_EXP ( in $DATEDIFF days)"
  [[ $DATEDIFF -lt $SSL_DUE ]] && report $LOGGER_MESSAGE

}


### Pre-checks
##############################
## Check bins
if ( [[ !( -x $DATE ) ]] || [[ !( -x $GREP ) ]] || [[ !( -x $AWK ) ]] || [[ !( -x $LOGGER ) ]] )	# without tmsh
#if ( [[ !( -x $DATE ) ]] || [[ !( -x $GREP ) ]] || [[ !( -x $AWK ) ]] || [[ !( -x $LOGGER ) ]] || [[ !( -x $TMSH ) ]] )	# full check
then
  LOGGER_MESSAGE="$ERR unable to execute binary"        # message in case of trouble with bins
  FATAL='1'
  report $LOGGER_MESSAGE
fi


### Execution
##############################
for i in $( ./example.sh )                              # echo script for testing
#for i in $( echo y | $TMSH -c 'list sys file ssl-cert expiration-string' ) # tmsh input
do
  if [[ $i =~ ssl-cert  ]]                              # additional regex check of input
    then
      # get ssl filename
      SSL_CRT=$( echo $i | $AWK '/ssl-cert/' | $AWK '{ print $4 }' )
      # get ssl expiration date
      SSL_EXP=$( echo $i | $AWK '/expiration-string/' | $AWK '{ gsub("\"","@@",$0); print $0 }' | $AWK -F'[@@|@@]' '{ print $3 }' )
  fi

  # check null variables
  if ( [[ -z $SSL_CRT ]] || [[ -z $SSL_EXP  ]] )
    then
      LOGGER_MESSAGE="$ERR one variable is empty. Cannot proceed with ssl-checking"
      FATAL='1'
      report "$LOGGER_MESSAGE"
  fi

  # validating date
  $DATE "+%Y%m%d" -d "$SSL_EXP">/dev/null 2>/dev/null
  if [[ !( $? == 0 )  ]]
    then
      LOGGER_MESSAGE="$ERR date validation has been failed"
      FATAL='1'
      report "$LOGGER_MESSAGE"
  fi

  # invoke diff function
  date_diff "$SSL_EXP"
done

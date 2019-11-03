#!/bin/sh
# FILE: "check_rtmp"
# DESCRIPTION:nagios plugin for checking rtmp streams.
# REQUIRES: rtmpdump (http://rtmpdump.mplayerhq.hu/)
#

PROGNAME=`readlink -f $0`
PROGPATH=`echo $PROGNAME | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION=`echo '$Revision: .2 $' | sed -e 's/[^0-9.]//g'`

RTMPDUMP=`which rtmpdump`

print_usage() {
  echo "Usage:"
  echo "  $PROGNAME -u <url> -t <timeout> "
  echo "  $PROGNAME -h "

  
}

print_help() {
  echo $PROGNAME $REVISION
  echo ""
  print_usage
  
	echo "Check the status of RTMP stream"
	echo ""
	echo "Opcions:"
	echo "	-u URL a testejar Exemple: rtmp://server/app/streamName"
	echo "	-t Time to monitor the stream"
	echo ""
  exit $STATE_UNKNOWN
}



STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

URL=""
TIMEOUT=2

# Proces de parametres
while getopts ":u:t:h" Option
do
	case $Option in 
		u ) URL=$OPTARG;;
		t ) TIMEOUT=$OPTARG;;
		h ) print_help;;
		* ) echo "Unimplemented option";;
		
		esac
done

if [ ! $URL ] ; then 
	echo " Error - No URL specified to monitor "
	echo ""
	print_help
	echo ""
	exit $STATE_UNKNOWN
fi

# Construct a temp name
ERR=`mktemp /tmp/check_rtmp_err_XXXXXXXXX`

# Test it
timeout --preserve-status `echo $(($TIMEOUT+2))` $RTMPDUMP --live -r $URL --stop $TIMEOUT > /dev/null 2> $ERR
status=$?


# Parse the results
CONNECTA=`grep "INFO: Connected" $ERR`

video_width=`grep displayWidth $ERR | awk '{print $NF}' | cut -d\. -f1`
video_height=`grep displayHeight $ERR | awk '{print $NF}' | cut -d\. -f1`
video_framerate=`grep framerate $ERR | awk '{print $NF}'`
video_vid_bitrate=`grep videodatarate $ERR| awk '{print $NF}'`
video_aud_bitrate=`grep audiodatarate $ERR | awk '{print $NF}'`

if [ -z "$CONNECTA" ]
then
  echo "CRITICAL - No connection to server: $URL"
  exit $STATE_CRITICAL
else
   ERROR=`grep "INFO: Metadata:" $ERR`
   if [ ! -z "$ERROR" ]
   then
       echo "OK - Stream working: $URL | video_width=$video_width video_height=$video_height video_framerate=$video_framerate video_video_bitrate=$video_vid_bitrate video_audio_bitrate=$video_aud_bitrate"
       exit $STATE_OK
    fi
    echo "CRITICAL - Stream NOT working: $URL"
    exit $STATE_CRITICAL
fi

echo "UNKNOWN - Something wrong hapened. Review the check."
exit $STATE_UNKNOWN

#!/bin/bash

# Default values
LOG_INTERVAL='15s'

# Help message --- {{{
usage () {
	echo -e \\n"Executes and monitors the given task for memory usage."\\n
	echo -e "Usage: $0 [-t NUM] [-c COMMAND]"\\n
	echo "Options:"
	echo "-c STR            Command to execute. Command should be wrapped in double/single quotes."
	echo -e """-t NUM[SUFFIX]    Log at every NUM seconds. SUFFIX can be 's' for seconds, 'm' for minutes, 'h' for hours or 'd' for days.
	          If no SUFFIX is provided, 's' is assumed. Default is 15s."""
	echo -e "-h                Prints help message."\\n
	exit 1
}
# }}} ---

# getopts --- {{{
while getopts c:t:h flags
do
	case "${flags}" in
		c) COMMAND=${OPTARG};;
		t) LOG_INTERVAL=${OPTARG};;
		h) usage;;
		?) echo -e \\n"Use -h to see the help documentation."\\n; exit 2;;
	esac
done

if [[ -z $COMMAND ]]; then echo -e \\n"[ERRR] Required argument -c missing."; usage; exit 1; fi
# }}}  ---

# Run command and monitor memory usage --- {{{
$COMMAND &
PID=$!

if ps -p $PID > /dev/null
then
	echo "[INFO] Job: $COMMAND"
	echo "[INFO] Logging at every $LOG_INTERVAL"
	echo "[INFO] Job initiated successfully [PID: ${PID}]"
	echo -e "[`date +"%D %T"`]\tPID\tETIME\t%CPU\t%MEM\t#MEM\tCMD" > tmp_mem_usage.log
	echo "[INFO] Monitoring started"
	
	while ps -p $PID > /dev/null;
	do
		TIMESTAMP=`date +"%D %T"`
		echo "[${TIMESTAMP}]" | paste - <(ps o pid,etime,%cpu,%mem,comm $PID | tail -1) | paste - <(pmap $PID | tail -n 1 | awk '/[0-9]K/{print $2}') | awk '{print $1" "$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$8"\t"$7}' >> tmp_mem_usage.log;
		sleep $LOG_INTERVAL;
	done;
	echo "[INFO] Job completed"
	
	column -t tmp_mem_usage.log > ${PID}_mem_usage.log
	rm tmp_mem_usage.log
	
	echo "[INFO] Memory usage log file: ${PID}_mem_usage.log"
else
	echo "[ERRR] Aborted. Please check your command and try again." 
fi

exit 0
# }}} ---


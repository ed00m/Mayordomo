#!/bin/bash
jobidfromstring()
{
	local STRING;
	local RET;
	STRING=$1;
	RET=$(echo $STRING | sed "s/^[^0-9]*//" | sed "s/[^0-9].*$//")
	echo $RET;
}
runmultitask()
{
	JOBLIST=""
	TASKLIST[0]=""
	i=0
	for TASK in "$@"
	do
		$TASK &
		LASTJOB=`jobidfromstring $(jobs %%)`
		JOBLIST="$JOBLIST $LASTJOB"
		TASKLIST[$i]=$TASK
		i=$(($i+1))
	done
	i=0
	for JOB in $JOBLIST ; do
		wait %$JOB
		echo "${TASKLIST[$i]} – Job $JOB exited with status $?"
		i=$(($i+1))
	done
}
runmultitask './genera_data.sh' './genera_data.sh' './genera_data.sh' './genera_data.sh' './genera_data.sh' './genera_data.sh' './genera_data.sh' './genera_data.sh'

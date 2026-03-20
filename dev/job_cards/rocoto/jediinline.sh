#! /usr/bin/env bash

source "${HOMEgfs}/ush/preamble.sh"

###############################################################
# Source FV3GFS workflow modules
# TODO clean this up once ncdiag/1.1.2 is installed on WCOSS2
source "${HOMEglobal}/ush/detect_machine.sh"
if [[ "${MACHINE_ID}" == "wcoss2" ]]; then
    source "${HOMEglobal}/dev/ush/load_modules.sh" ufswm
else
    source "${HOMEglobal}/dev/ush/load_modules.sh" run
fi
status=$?
[[ ${status} -ne 0 ]] && exit ${status}

export job="jediinline"
export jobid="${job}.$$"

# Execute the JJOB
"${HOMEglobal}/dev/jobs/JJEDI_INLINE"
status=$?

exit ${status}

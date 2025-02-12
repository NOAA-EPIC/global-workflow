#! /usr/bin/env bash
set -x

source "${USHgfs}/preamble.sh"
export GDASsorc=/scratch1/NCEPDEV/nems/David.Burrows/feb4_mark_updates/gw_jedi_soca_uwtools_update/sorc/gdas.cd
export GENEXPsorc=/scratch1/NCEPDEV/nems/David.Burrows/feb4_mark_updates

echo "$PYTHONPATH"
module list
unset PYTHONPATH

source ${GDASsorc}/bundle/venv/uwtools/bin/activate

cp -pr ${GENEXPsorc}/gen-exp ${DATA}
chmod 766 ${GENEXPsorc}/gen-exp
cd ${DATA}/gen-exp

python ${HOMEgfs}/scripts/exjedi_inline.py
export err=$?;
if [ ${err} -ne 0 ]; then exit 1; fi
cat ${pgmout}

deactivate

cp ${GDASsorc}/build/bin/fv3jedi_letkf.x ${DATA}
srun --export=ALL -n 12 ${GDASsorc}/build/bin/fv3jedi_letkf.x testinput/letkf-c48-exp.yaml

exit 0

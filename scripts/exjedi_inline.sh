#! /usr/bin/env bash

source "${USHgfs}/preamble.sh"
export GDASsorc=/scratch1/NCEPDEV/nems/David.Burrows/feb4_mark_updates/gw_jedi_soca_uwtools_update/sorc/gdas.cd
export GENEXPsorc=/scratch1/NCEPDEV/nems/David.Burrows/feb4_mark_updates

echo "$PYTHONPATH"
module list
unset PYTHONPATH

source ${GDASsorc}/bundle/venv/uwtools/bin/activate

python /scratch1/NCEPDEV/nems/David.Burrows/feb3_inline/global-workflow/scripts/exjedi_inline.py

deactivate

cp -pr ${GENEXPsorc}/gen-exp ${DATA}
cd ${DATA}/gen-exp

cp ${GDASsorc}/build/bin/fv3jedi_letkf.x .
srun --export=ALL -n 12 ${GDASsorc}/build/bin/fv3jedi_letkf.x testinput/letkf-c48-exp.yaml

exit 0

#!/bin/bash

source /scratch1/NCEPDEV/nems/David.Burrows/feb4_mark_updates/gw_jedi_soca_uwtools_update/sorc/gdas.cd/bundle/venv/uwtools/bin/activate

python /scratch1/NCEPDEV/nems/David.Burrows/feb3_inline/global-workflow/scripts/exjedi_inline.py

srun -n 12 /scratch1/NCEPDEV/nems/David.Burrows/feb4_mark_updates/gw_jedi_soca_uwtools_update/sorc/gdas.cd/build/bin/fv3jedi_letkf.x /scratch1/NCEPDEV/nems/David.Burrows/feb4_mark_updates/gen-exp/testinput/letkf-c48-exp.yaml

deactivate

exit 0

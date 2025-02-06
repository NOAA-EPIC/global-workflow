#!/usr/bin/env python

#source "${USHgfs}/preamble.sh"
from pathlib import Path
from shutil import rmtree
from uwtools.api import fs
from uwtools.api.logging import use_uwtools_logger
from uwtools.api import config
from uwtools.api import template
import os
from os import listdir
from os.path import isfile, join

use_uwtools_logger()

da_nx=1
da_ny=2
fc_nx=1
fc_ny=1
ens_size=2
data_dir="./c48_input_data"
top_template_dict = {}
fc_template_dict = {}
top_template_dict["da_nx"]=da_nx
top_template_dict["da_ny"]=da_ny
top_template_dict["rundir"]="ModelRunDirs/c48_001"

fc_template_dict["fc_nx"]=fc_nx
fc_template_dict["fc_ny"]=fc_ny
fc_template_dict["fc_ny"]=fc_ny

forecast_yamls = {}
rundir_dict = {}
ensemble_dict = {}

# set up dictionaries
for mem in range(1, ens_size+1):
  rundir = f"ModelRunDirs/c48_{mem:03d}"
  filename = f"testinput/forecast_c48_{mem:03d}.yaml"
  label = f"forecast_configuration_{mem}"
  ensemble_dict[label] = mem
  forecast_yamls[label]=filename
  rundir_dict[label]=rundir
  print("{},{}".format(label,filename))

# create top level template with all input files in it   
inputfile = open('templates/letkf-c48-top.template', 'r').readlines()
write_file = open('templates/letkf-c48-top-full.template','w')
for line in inputfile:
    write_file.write(line)
    if 'Forecast configuration:' in line:
       for label, filename in forecast_yamls.items():
            new_line = "  - %s " %(filename)        
            write_file.write(new_line + "\n") 
write_file.close()

# render the top template
template.render(
        values_src=top_template_dict,
        values_format='dict',
        input_file='templates/letkf-c48-top-full.template',
        output_file='testinput/letkf-c48-exp.yaml'
    )


# create the forecast yamls
for label, filename in forecast_yamls.items():
  fc_template_dict["run_dir"] = rundir_dict[label]
  fc_template_dict["ensemble_num"] = ensemble_dict[label]
  template.render(
        values_src=fc_template_dict,
        values_format='dict',
        input_file='templates/letkf_c48_forecast_ufs.template',
        output_file=filename
    )

# create run directories and copy in files
onlyfiles = [os.path.join(data_dir, f) for f in os.listdir(data_dir) if os.path.isfile(os.path.join(data_dir, f))]
rundir_file = open('rundir-files.yaml','w')
for file in onlyfiles:
  if("ufs.configure" not in file and "input.nml" not in file):
    basefile = os.path.basename(file)
    newline = f"{basefile}: {file}"
    rundir_file.write(newline + "\n")
rundir_file.close()

input_nml_dict = {}
input_nml_dict["fc_nx"]=fc_nx
input_nml_dict["fc_ny"]=fc_ny
input_nml_dict["ensemble_size"]=ens_size
input_nml_dict["atm_procs"]=fc_nx*fc_ny*6 - 1
for mem in range(1, ens_size+1):
  rundir = f"ModelRunDirs/c48_{mem:03d}"
  inputdir = f"./c48_input_data/INPUT" 
  input_nml_dict["inputdir"]=inputdir
  input_nml_dict["ENS_XX"]=f"ens_{mem:02d}"
  input_nml_dict["iseed_skeb"]=mem*3
  input_nml_dict["iseed_shum"]=mem*3 + 1
  input_nml_dict["iseed_sppt"]=mem*3 + 2
  fs.link(
    config="rundir-files.yaml",
    target_dir=Path(rundir)
    ) 
  os.mkdir(os.path.join(rundir, "RESTART"))
  template.render(
        values_src=input_nml_dict,
        values_format='dict',
        input_file='templates/c48_input.template',
        output_file=os.path.join(rundir,"input.nml")
   )
  template.render(
        values_src=input_nml_dict,
        values_format='dict',
        input_file='templates/ufs.configure.template',
        output_file=os.path.join(rundir,"ufs.configure")
   )
  template.render(
        values_src=input_nml_dict,
        values_format='dict',
        input_file='templates/input-c48-files.template',
        output_file="templates/input-links.template"
   )
  fs.link(
    config="templates/input-links.template",
    target_dir=Path(os.path.join(rundir, "INPUT"))
  )

#exit "${err}" commented out by AlexB; leading to invalid syntax

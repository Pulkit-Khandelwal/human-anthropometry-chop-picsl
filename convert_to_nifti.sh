export FREESURFER_HOME=/Applications/freesurfer/7.1.1
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh


subjects=(SAyr10BF001
SAyr10BF002
SAyr10BF003
SAyr10BF004
SAyr10BF005
SAyr10BF006
SAyr10BF007
SAyr10BF008
SAyr10BF009
SAyr10BF010
SAyr10BM001
SAyr10BM002
SAyr10BM003
SAyr10BM004
SAyr10BM005
SAyr10BM006
SAyr10BM007
SAyr10BM008
SAyr10BM009
SAyr10BM010
SAyr10WF001
SAyr10WF002
SAyr10WF003
SAyr10WF004
SAyr10WF005
SAyr10WF006
SAyr10WF007
SAyr10WF008
SAyr10WF009
SAyr10WF010
SAyr10WM001
SAyr10WM002
SAyr10WM003
SAyr10WM004
SAyr10WM005
SAyr10WM006
SAyr10WM007
SAyr10WM008
SAyr10WM009
SAyr10WM010)


curr_dir=/Volumes/Pulkit_WD/skullTemplates/all_data/ten

for name in "${subjects[@]}"

do
  echo ${name}

  # get the folder name with the largest number of files

  cd ${curr_dir}/${name}
  variable_name=$(du -a | cut -d/ -f2 | sort | uniq -c | sort -nr | head -n 1)
  folder_name="${variable_name:5}"

  echo "folder name: " ${folder_name}

  # get the run number
  ss=$(dcmunpack -src ${curr_dir}/${name}/${folder_name})
  echo "dicom file details: " ${ss}

  run_number=$(echo $ss | awk -v FS="(series: | Subject)" '{print $2}')
  echo "run number: " ${run_number}

  cd ${curr_dir}

  # convert to nifti and save in the mri folder
  echo "converting to nifti....."

  no_output=$(dcmunpack -src ${curr_dir}/${name}/${folder_name} -targ . -run ${run_number} mri nii ${name})

done

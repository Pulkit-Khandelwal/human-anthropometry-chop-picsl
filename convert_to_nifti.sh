export FREESURFER_HOME=/Applications/freesurfer/7.1.1
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh


subjects=(SAyr5BF001
SAyr5BF002
SAyr5BF003
SAyr5BF004
SAyr5BF005
SAyr5BF006
SAyr5BF007
SAyr5BF008
SAyr5BF009
SAyr5BF010
SAyr5BM001
SAyr5BM002
SAyr5BM003
SAyr5BM004
SAyr5BM005
SAyr5BM006
SAyr5BM007
SAyr5BM008
SAyr5BM009
SAyr5BM010
SAyr5WF001
SAyr5WF002
SAyr5WF003
SAyr5WF004
SAyr5WF005
SAyr5WF006
SAyr5WF007
SAyr5WF008
SAyr5WF009
SAyr5WF010
SAyr5WM001
SAyr5WM002
SAyr5WM003
SAyr5WM004
SAyr5WM005
SAyr5WM006
SAyr5WM007
SAyr5WM008
SAyr5WM009
SAyr5WM010)


curr_dir=/Volumes/Pulkit_WD/skullTemplates/all_data/five

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

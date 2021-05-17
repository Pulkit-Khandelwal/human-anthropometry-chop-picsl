
export FREESURFER_HOME=/Applications/freesurfer/7.1.1
export SUBJECTS_DIR=$FREESURFER_HOME/subjects
source $FREESURFER_HOME/SetUpFreeSurfer.sh




subject_name="SAyr10WM010"

cd /Volumes/Pulkit_WD/skullTemplates/all_data/ten/SAyr10WM010/
variable_name=$(du -a | cut -d/ -f2 | sort | uniq -c | sort -nr | head -n 1)
folder_name="${variable_name:5}"

echo $folder_name

ss=$(dcmunpack -src /Volumes/Pulkit_WD/skullTemplates/all_data/ten/SAyr10WM010/${folder_name})

echo $ss

run_number=$(echo $ss | awk -v FS="(series: | Subject)" '{print $2}')

echo $run_number

cd ..

convert_to_nifti=$(dcmunpack -src /Volumes/Pulkit_WD/skullTemplates/all_data/ten/SAyr10WM010/${folder_name} -targ . -run ${run_number} mri nii ${subject_name})

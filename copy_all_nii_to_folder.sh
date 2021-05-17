

num="six"

curr_dir=/Volumes/Pulkit_WD/skullTemplates/all_data/${num}
to_dir=/Volumes/Pulkit_WD/skullTemplates/all_data/nifti_files

mkdir ${to_dir}/${num}

array=(`find ${curr_dir} -name "*.nii"`)

for name in "${array[@]}"

do
  echo ${name}

  cp ${name} ${to_dir}/${num}

done

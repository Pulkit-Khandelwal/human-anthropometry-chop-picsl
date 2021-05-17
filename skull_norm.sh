
array=(SAyr10BF001.nii
SAyr10BF002.nii
SAyr10BF003.nii
SAyr10BF004.nii
SAyr10BF005.nii
SAyr10BF006.nii
SAyr10BF007.nii
SAyr10BF008.nii
SAyr10BF009.nii
SAyr10BF010.nii)


num="ten"
dir1=/Volumes/Pulkit_WD/skullTemplates/all_data/nifti_files/${num}
dir2=/Volumes/Pulkit_WD/skullTemplates/all_data/nifti_files/norm/${num}

mkdir /Volumes/Pulkit_WD/skullTemplates/all_data/nifti_files/norm/${num}


for name in "${array[@]}"

do
  echo ${name}

  c3d ${dir1}/${name} -stretch 0.1% 99.9% 0 1000 -clip 0 1000 -o ${dir2}/${name}

done

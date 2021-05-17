subjects=(SAyr3BF001
SAyr3BF002
SAyr3BF003
SAyr3BF004
SAyr3BF005
SAyr3BF006
SAyr3BF007
SAyr3BF008
SAyr3BF009
SAyr3BF010
SAyr3BM001
SAyr3BM002
SAyr3BM003
SAyr3BM004
SAyr3BM005
SAyr3BM006
SAyr3BM007
SAyr3BM008
SAyr3BM009
SAyr3BM010
SAyr3WF001
SAyr3WF002
SAyr3WF003
SAyr3WF004
SAyr3WF005
SAyr3WF006
SAyr3WF007
SAyr3WF008
SAyr3WF009
SAyr3WF010
SAyr3WM001
SAyr3WM002
SAyr3WM003
SAyr3WM004
SAyr3WM005
SAyr3WM006
SAyr3WM007
SAyr3WM008
SAyr3WM009)


curr_dir=/Volumes/Pulkit_WD/skullTemplates/all_data/three

for name in "${subjects[@]}"

do
  echo ${name}
  mkdir ${curr_dir}/${name}

  unzip ${curr_dir}/${name}.zip -d ${curr_dir}/${name}

done

function fn_template_ncc_loop
{
  # Which template are we building (ncc or aff_ncc)
  mode=${1?}

  # List of subjects
  N=$(cat $ROOT/scripts/subj24.txt | wc -l)

  # Iterations - number, starting
  SITER=0

  # Perform the loop
    for ((iter=$SITER; iter<${NCC_NITER}; iter++));do

    # Create a working directory for this iteration
    WORK=$WDIR/template_${mode}/iter${iter}
    mkdir -p $WORK/dump

    # Compute current average for each modality
        for mod in img phg; do
                qsubp4 -cwd -o $WORK/dump -j y -N "average_${iter}_${mod}" \
                $0 fn_template_ncc_average $iter $mod $mode
        done

    # Wait for completion
    qsub -cwd -o $WORK/dump -j y -hold_jid "average_${stage}*" -sync y -b y sleep 1

    # register all images to the average and place in new folder for iter+1:
        for ((i=1;i<=$N;i++)); do
      # submit ANTS job:
                qsubp4 -l h_vmem=30G,s_vmem=29.9G -cwd -o $WORK/dump -j y -N "norm_${iter}_${i}" \
                $0 fn_template_ncc_register ${i} ${iter} ${mode}
        done

                # Wait for completion
                qsub -cwd -o $WORK/dump -j y -hold_jid "norm_${stage}*" -sync y -b y sleep 1

   done
}

# average images from iteration iter
function fn_template_ncc_average()
{
  # Iteration
  iter=${1?}

  # Modality
  mod=${2?}

  # Which template are we building (ncc or aff_ncc)
  mode=${3?}

  # Directory where to average
  WORK=$WDIR/template_${mode}/iter${iter}
  mkdir -p $WORK

  # List images to average
  if [[ $iter -eq 0 ]]; then

    if [[ $mode == "ncc" ]]; then
      # The inputs are in the paths directories
      INPUTS=$(ls $WDIR/gshoot/*/iter_$((GSHOOT_NITER-1))/reslice*${mod}*.nii.gz)
    elif [[ $mode == "aff_ncc" ]]; then
      INPUTS=$(ls $WDIR/template_${mode}/input/*/reslice*${mod}*.nii.gz)
    fi

  else

    # The inputs are outputs from last iteration
    INPUTS=$(ls $WDIR/template_${mode}/iter$((iter-1))/reslice*${mod}*.nii.gz)

  fi

  # Type of averaging to perform
  AVGMODE=0
  # This seems to make things worse
  if [[ $mod == "img" ]]; then AVGMODE=1; fi

  # Do the averaging
  ${ANTSDIR}/AverageImages 3 $WORK/template_${mod}.nii.gz $AVGMODE ${INPUTS}

  # Scale template by 100 - why?
  if [[ $mod == "img" ]]; then
    c3d $WORK/template_${mod}.nii.gz -scale 100 -o $WORK/template_${mod}.nii.gz
  fi

  # Compute the mask
  if [[ $mod == "phg" ]]; then
    c3d $WORK/template_phg.nii.gz -thresh 0.5 inf 1 0 -dilate 1 10x10x10vox -o $WORK/template_mask.nii.gz
  fi
}


# This is the registration part of the groupwise intensity registration script.
# It can be run on full MST/GS output or on the affine part of it, the latter
# being a simulation of what conventional template building would produce on
# this dataset
function fn_template_ncc_register()
{
  # The index of the subject being registered using the MST
  idx=${1?}
  iter=${2?}

  # The mode for this function (ncc or aff_ncc)
  mode=${3?}

  # The work directory
  WORK=$WDIR/template_${mode}/iter${iter}

  # The ID of the subject
  ID=$(cat $ROOT/scripts/subj24.txt | head -n $idx | tail -n 1)

  # The native space images and registrations
  SEG_SHAPEONLY=0
  read IMG_NAT PHG_NAT <<<$(fn_input_unwarped_images $ID $SEG_SHAPEONLY)

  # The iteration path for gshoot
  GSDIR=$WDIR/gshoot/${ID}/iter_$((GSHOOT_NITER-1))

  # Build up the warp chain - all the 'shape' warps
  if [[ $mode == "ncc" ]]; then
    WARPCHAIN="$GSDIR/shooting_warp.nii.gz $GSDIR/target_to_root_procrustes.mat,-1"
    IMGMOV=$(ls $GSDIR/reslice_*img.nii.gz)
    PHGMOV=$(ls $GSDIR/reslice_*phgint.nii.gz)
  elif [[ $mode == "aff_ncc" ]]; then
    WARPCHAIN="$WDIR/template_${mode}/input/$ID/proc_affine_${ID}.mat"
    IMGMOV=$(ls $WDIR/template_${mode}/input/$ID/reslice_*img.nii.gz)
  fi

  # Template
  TEMPLATE_IMG=$WORK/template_img.nii.gz

  # Pattern for reslicing
  RESLICE_PTRN=$WORK/reslice_to_template_${ID}_XXX.nii.gz

  # Create the working directory
  mkdir -p $WORK

 # Symlink the moving image in this directory
  ln -sf $IMGMOV $WORK/moving_${ID}_img.nii.gz

  # The output warp
  #WARP=$WORK/warp_template_to_${ID}.nii.gz

  # The output warp - root
  WARP_ROOT=$WORK/warp_root_template_to_${ID}.nii.gz

# Compute the mask over the moving image - only need to do this once
if [[ $iter -eq 0 ]]; then
c3d $PHGMOV -thresh 1 1 1 0 -dilate 1 10x10x10vox -as VISIBLE $PHGMOV -thresh 2 2 1 0 -dilate 1 2x2x2vox -insert VISIBLE  2 -scale -1 -add -o $WDIR/template_${mode}/moving_${ID}_mask.nii.gz
fi

# Perform registration with NCC -
# Greedy only supports a mask over the fixed image. Reverse the order of the registration
# so that the template is warped to the subject space. The subject can then be warped to the template
# space using the inverse warp ( root,-64)
$GREEDY_HOME/greedy -d 3 \
  -w 1 -m NCC 2x2x2 -i $IMGMOV $TEMPLATE_IMG \
  -gm $WDIR/template_${mode}/moving_${ID}_mask.nii.gz  \
  -n 100x100x50 -s 0.6mm 0.2mm -e 0.5 \
  -threads $NSLOTS \
  -sv -wp 0 -oroot $WARP_ROOT \

# to save storage, don't need to save full warp here. Only the root.

<< "TEMPLATE_FIXED"
$GREEDY_HOME/greedy -d 3 \
  -w 1 -m NCC 2x2x2 -i $TEMPLATE_IMG $IMGMOV \
  -gm $WORK/template_mask.nii.gz \
  -n 100x100x50 -s 0.6mm 0.2mm -e 0.5 \
  -threads $NSLOTS \
  -sv -wp 0 -oroot $WARP_ROOT \
  -o $WARP
TEMPLATE_FIXED

# Apply registration at this iteration
reslice_subj $ID $TEMPLATE_IMG $RESLICE_PTRN "$WARP_ROOT,-64" $WARPCHAIN
}

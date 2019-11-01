#!/bin/sh

# Usage:
#          
#    mri_convert_batch.sh <<subj1 dir> <subj2 dir> ... <subN dir>>
#
# Example:
#
#     ../scripts/mri_convert_batch.sh WELM34 YESB65
#


# Run this in this script root subject sirectory
for i in $*
do
    if [ ! -f $i/mri/T1.nii ] ; then
	mri_convert $i/mri/T1.mgz    $i/mri/T1.nii 
    fi
    if [ ! -f $i/mri/aseg.nii ] ; then
	mri_convert $i/mri/aseg.mgz  $i/mri/aseg.nii 
    fi
    if [ ! -f $i/mri/brain.nii ] ; then
	mri_convert $i/mri/brain.mgz $i/mri/brain.nii 
    fi
    if [ ! -f $i/mri/wm.nii ] ; then
	mri_convert $i/mri/wm.mgz    $i/mri/wm.nii 
    fi
done

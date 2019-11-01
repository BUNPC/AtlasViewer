function vol2surf = get_mri_vol2surf(mri)

vol2surf = [mri.vox2ras(1:3,1:3), mri.vox2ras(1:3,4)-[mri.c_r; mri.c_a; mri.c_s]; [0,0,0,1]];


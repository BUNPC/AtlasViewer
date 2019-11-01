function status = gen_mri_nifti_files(dirname)

status = 0;
flags=zeros(4,1);

filelist='';
if ~exist([dirname, 'T1.nii'], 'file')
    filelist='T1.nii; ';
    flags(1) = 1;
end
if ~exist([dirname, 'brain.nii'], 'file')
    filelist=sprintf('%sbrain.nii; ', filelist);
    flags(2) = 1;
end
if ~exist([dirname, 'aseg.nii'], 'file')
    filelist=sprintf('%saseg.nii; ', filelist);
    flags(3) = 1;
end
if ~exist([dirname, 'wm.nii'], 'file')
    filelist=sprintf('%swm.nii; ', filelist);
    flags(4) = 1;
end
if sum(flags)>0
    UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
    set(0, 'DefaultUIControlFontSize', 12);
    menu(sprintf('Warning: Missing the following required nifti files: %s.\n', filelist), 'OK');
    set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
end


%if flags(1)>0 | (flags(2)>0 & flags(3)>0)
if flags(1)>0 || flags(3)>0
     status = 1;
end

